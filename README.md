# Mosquito Ninja — iOS app

A native UIKit customer-service app for Mosquito Ninja. The app uses native Home, Services, Appointments, Quote, Prep, and Contact experiences, with bundled website pages used only for deeper reference content.

## Native iOS features

- Native service dashboard and navigation.
- Native quote request flow with a single in-app review/send sheet and feedback after iOS reports the result.
- Optional property-photo attachments with previews and preserved quote-form state.
- **Appointments center** with confirmed service date/time, service type, property label, notes, and service-day tools.
- **My Service dashboard** with premium appointment status and local service history.
- **Privacy-first local appointment alerts** at 24 hours and 1 hour before service.
- Appointment notification permission is requested only when the customer chooses reminders.
- Appointment information is stored on the customer’s device using `UserDefaults`.
- Optional, on-demand service-area check using iOS location/geocoding. No background location tracking.
- Native service-prep guide.
- Text buttons and bundled `sms:` links use Apple's in-app message composer. `tel:` and `mailto:` links open the appropriate iOS app.
- Bundled service/reference pages remain available offline.
- Website-matched theatrical launch overlay with the transparent `MOSQUITO NINJA / BITE BACK!` lockup, an accurately aligned animated strike, and Reduce Motion support.
- iPhone and iPad support, iOS 15+.
- No Push Notifications entitlement, Associated Domains, camera, microphone, or location capability is required for the current local-reminder implementation.

## Appointment reminder behavior

When a confirmed appointment is saved in the app, the customer can enable:

- a reminder 24 hours before service;
- a reminder 1 hour before service.

These are local iOS notifications. Appointment reminders do not use GPS or route tracking. If notification permission is disabled, the appointment remains saved and the app explains how to enable alerts in Settings.

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

## In-app messaging

Quotes and texts use `MFMessageComposeViewController`. Customers review once and tap Send inside the app. No backend or SMS-provider credentials are required. The device must be configured for messaging; unsupported devices keep the customer in the app and offer an explicit copy action.

Completion feedback follows the MessageUI delegate result after the sheet dismisses. Apple's `.sent` means queued or sent, not delivered or received; the app makes no delivery or quote-acceptance guarantee. Replies arrive in Messages. Cancelling or failing leaves the native quote form intact for retry. MessageUI exposes initial content, so edits made inside Apple's composer are not promised to be saved. No new server storage or persistent draft storage is introduced.

Physical-device checks required before release:

- Quote: invalid fields stay in the form; valid details open one composer addressed to 609-313-6317.
- Text: Home, Contact, Appointments and bundled-page links all open a composer without switching apps.
- Send, cancel and failure each dismiss once, then show the correct result; cancelling/failing keeps the original quote form details.
- Repeated taps do not stack composers; emoji, ampersands and multiline notes remain intact.
- A device without messaging gets a clear unavailable state and optional copy action.
- Check iPhone/iPad sheet layout, keyboard dismissal, VoiceOver and Reduce Motion.

Reference: https://developer.apple.com/documentation/messageui/mfmessagecomposeviewcontroller

## Independent app strengths update

- Native mosquito, tick, and commercial/government detail screens adapt the website's clearer service explanation into app-owned Swift content and native cards. Home, Services and internal reference-page service links open these screens.
- Request this service selects the matching quote option while preserving entered contact/property fields.
- The preparation guide is reachable from Services and each native service detail screen.
- Native reading components support Dynamic Type. Existing hero, tabs, local appointments, location check and in-app messaging remain in the app.
- No source files, build process or UI module are shared with the website. The existing public service-area configuration feed is unchanged.

Before release, build in Xcode and test service navigation/back behavior, service-to-quote preselection with a partially completed form, preparation navigation, large text, iPhone/iPad layouts, and the existing MessageUI flow. Source parsing alone does not verify an iOS build.
