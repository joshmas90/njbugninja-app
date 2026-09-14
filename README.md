# Mosquito Ninja — iOS app

A native UIKit customer-service app for Mosquito Ninja. The app uses native Home, Services, Appointments, Quote, Prep, and Contact experiences, with bundled website pages used only for deeper reference content.

## Native iOS features

- Native service dashboard and navigation.
- Native quote request flow that prepares a message for review in Messages.
- **Appointments center** with confirmed service date/time, service type, property label, notes, and service-day tools.
- **Privacy-first local appointment alerts** at 24 hours and 1 hour before service.
- Appointment notification permission is requested only when the customer chooses reminders.
- Appointment information is stored on the customer’s device using `UserDefaults`.
- **No live location tracking or location permission.**
- Native service-prep guide.
- `tel:`, `sms:`, and `mailto:` links open the appropriate iOS app.
- Bundled service/reference pages remain available offline.
- iPhone and iPad support, iOS 15+.
- No Push Notifications entitlement, Associated Domains, camera, microphone, or location capability is required for the current local-reminder implementation.

## Appointment reminder behavior

When a confirmed appointment is saved in the app, the customer can enable:

- a reminder 24 hours before service;
- a reminder 1 hour before service.

These are local iOS notifications. No GPS or route tracking is used. If notification permission is disabled, the appointment remains saved and the app explains how to enable alerts in Settings.

This first premium appointment implementation intentionally keeps customer data on-device. A future owner-managed scheduling backend can sync confirmed appointments to customer devices and add server-driven push notifications without changing the customer-facing appointment design.

## Open in Xcode

1. Copy this folder to a Mac.
2. Open `MosquitoNinja.xcodeproj`.
3. Select the **MosquitoNinja** target → **Signing & Capabilities**.
4. Choose your Apple Developer Team.
5. Keep `com.njbugninja.app` if it is available to your account, or change the bundle identifier to one you control.
6. Select an iPhone/iPad or simulator and Run.

For App Store distribution: **Product → Archive → Distribute App → App Store Connect**.

## Verify

On any machine with Python:

```bash
python3 scripts/verify_bundle.py
```

On a Mac with Xcode:

```bash
./scripts/build-simulator.sh
```
