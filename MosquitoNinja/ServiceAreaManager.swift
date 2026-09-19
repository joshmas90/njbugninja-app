import Foundation
import CoreLocation

enum ServiceAreaCoverage: String, Decodable {
    case covered
    case confirm
    case outside
    case unverified
}

enum ServiceAreaRuleSource {
    case current
    case unavailable
}

struct ServiceAreaResult {
    let coverage: ServiceAreaCoverage
    let county: String?
    let postalCode: String?
    let message: String
    let approximate: Bool
    let ruleSource: ServiceAreaRuleSource
}

enum ServiceAreaError: LocalizedError {
    case permissionDenied
    case locationUnavailable
    case geocodingFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location access is turned off."
        case .locationUnavailable:
            return "Your current location could not be determined."
        case .geocodingFailed:
            return "Your county and ZIP code could not be identified."
        }
    }
}

private struct ServiceAreaCountyRule: Decodable {
    let status: ServiceAreaCoverage
    let includedZIPs: [String]?
    let excludedZIPs: [String]?
}

private struct ServiceAreaConfig: Decodable {
    let version: Int
    let state: String
    let defaultStatus: ServiceAreaCoverage
    let counties: [String: ServiceAreaCountyRule]
}

final class ServiceAreaManager: NSObject, CLLocationManagerDelegate {
    static let shared = ServiceAreaManager()

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private var completion:
        ((Result<ServiceAreaResult, Error>) -> Void)?

    private var waitingForPermission = false

    private override init() {
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func checkCurrentLocation(
        completion: @escaping
            (Result<ServiceAreaResult, Error>) -> Void
    ) {
        self.completion = completion

        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            requestLocationWithBestAvailableAccuracy()

        case .notDetermined:
            waitingForPermission = true
            locationManager.requestWhenInUseAuthorization()

        case .denied, .restricted:
            finish(.failure(ServiceAreaError.permissionDenied))

        @unknown default:
            finish(.failure(ServiceAreaError.locationUnavailable))
        }
    }

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        guard waitingForPermission else {
            return
        }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            waitingForPermission = false
            requestLocationWithBestAvailableAccuracy()

        case .denied, .restricted:
            waitingForPermission = false
            finish(.failure(ServiceAreaError.permissionDenied))

        case .notDetermined:
            break

        @unknown default:
            waitingForPermission = false
            finish(.failure(ServiceAreaError.locationUnavailable))
        }
    }

    private func requestLocationWithBestAvailableAccuracy() {
        if locationManager.accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(
                withPurposeKey: "ServiceAreaCheck"
            ) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.locationManager.requestLocation()
                }
            }
        } else {
            locationManager.requestLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard
            let location = locations.last(where: {
                $0.horizontalAccuracy >= 0
            })
        else {
            finish(.failure(ServiceAreaError.locationUnavailable))
            return
        }

        let approximate =
            manager.accuracyAuthorization == .reducedAccuracy

        geocoder.reverseGeocodeLocation(location) {
            [weak self] placemarks, error in

            guard let self else {
                return
            }

            guard
                error == nil,
                let placemark = placemarks?.first
            else {
                self.finish(
                    .failure(ServiceAreaError.geocodingFailed)
                )
                return
            }

            self.loadConfig { config in
                let result: ServiceAreaResult

                if let config {
                    result = self.evaluate(
                        placemark: placemark,
                        config: config,
                        approximate: approximate
                    )
                } else {
                    result = ServiceAreaResult(
                        coverage: .unverified,
                        county: placemark.subAdministrativeArea,
                        postalCode: placemark.postalCode,
                        message:
                            "Current service-area rules could not be loaded, so this location has not been confirmed. Try again or contact Mosquito Ninja for a direct route check.",
                        approximate: approximate,
                        ruleSource: .unavailable
                    )
                }

                self.finish(.success(result))
            }
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        finish(.failure(ServiceAreaError.locationUnavailable))
    }

    private func evaluate(
        placemark: CLPlacemark,
        config: ServiceAreaConfig,
        approximate: Bool
    ) -> ServiceAreaResult {
        let state =
            (placemark.administrativeArea ?? "").uppercased()

        let county = placemark.subAdministrativeArea
        let postalCode = placemark.postalCode

        if approximate {
            return ServiceAreaResult(
                coverage: .confirm,
                county: county,
                postalCode: postalCode,
                message:
                    "Precise Location was unavailable. " +
                    "Contact Mosquito Ninja to confirm this route.",
                approximate: true,
                ruleSource: .current
            )
        }

        guard state == config.state.uppercased() else {
            return ServiceAreaResult(
                coverage: .outside,
                county: county,
                postalCode: postalCode,
                message:
                    "This location is outside the current " +
                    "New Jersey service area.",
                approximate: false,
                ruleSource: .current
            )
        }

        let countyKey = normalizeCounty(county)

        guard let rule = config.counties[countyKey] else {
            return result(
                coverage: config.defaultStatus,
                county: county,
                postalCode: postalCode
            )
        }

        let included = rule.includedZIPs ?? []
        let excluded = rule.excludedZIPs ?? []

        if let postalCode, excluded.contains(postalCode) {
            return result(
                coverage: .outside,
                county: county,
                postalCode: postalCode
            )
        }

        if let postalCode, included.contains(postalCode) {
            return result(
                coverage: .covered,
                county: county,
                postalCode: postalCode
            )
        }

        return result(
            coverage: rule.status,
            county: county,
            postalCode: postalCode
        )
    }

    private func result(
        coverage: ServiceAreaCoverage,
        county: String?,
        postalCode: String?
    ) -> ServiceAreaResult {
        let message: String

        switch coverage {
        case .covered:
            message =
                "Mosquito Ninja currently services this configured area."

        case .confirm:
            message =
                "This location is in the South Jersey route region. " +
                "Contact Mosquito Ninja to confirm current availability."

        case .outside:
            message =
                "This location is outside the current configured " +
                "service area. Coverage can change as routes expand."

        case .unverified:
            message =
                "Current service-area rules could not be loaded, so coverage has not been verified."
        }

        return ServiceAreaResult(
            coverage: coverage,
            county: county,
            postalCode: postalCode,
            message: message,
            approximate: false,
            ruleSource: .current
        )
    }

    private func normalizeCounty(_ county: String?) -> String {
        var value = (county ?? "")
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if value.hasSuffix(" county") {
            value.removeLast(" county".count)
        }

        return value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private func loadConfig(
        completion:
            @escaping (ServiceAreaConfig?) -> Void
    ) {
        let stamp = Int(Date().timeIntervalSince1970)

        let urls = [
            URL(
                string:
                    "https://raw.githubusercontent.com/" +
                    "joshmas90/njbugninja/main/" +
                    "service-area-config.json?v=\(stamp)"
            )!,
            URL(
                string:
                    "https://njbugninja.com/" +
                    "service-area-config.json?v=\(stamp)"
            )!
        ]

        loadConfig(
            urls: urls,
            index: 0,
            completion: completion
        )
    }

    private func loadConfig(
        urls: [URL],
        index: Int,
        completion:
            @escaping (ServiceAreaConfig?) -> Void
    ) {
        guard index < urls.count else {
            completion(nil)
            return
        }

        var request = URLRequest(
            url: urls[index],
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 8
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in

            guard let self else {
                return
            }

            if
                error == nil,
                let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode),
                let data,
                let config = try? JSONDecoder().decode(
                    ServiceAreaConfig.self,
                    from: data
                )
            {
                DispatchQueue.main.async {
                    completion(config)
                }

                return
            }

            self.loadConfig(
                urls: urls,
                index: index + 1,
                completion: completion
            )
        }
        .resume()
    }

    private func finish(
        _ result: Result<ServiceAreaResult, Error>
    ) {
        DispatchQueue.main.async {
            let completion = self.completion
            self.completion = nil
            completion?(result)
        }
    }
}
