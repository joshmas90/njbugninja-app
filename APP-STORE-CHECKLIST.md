# App Store setup checklist

- App name: **Mosquito Ninja**
- Version: **1.0**
- Build: assigned by CodeMagic for each archive
- Default bundle identifier in project: `com.njbugninja.app`
- Minimum iOS: **15.0**
- Devices: **iPhone + iPad**
- Encryption declaration: non-exempt encryption = **No**
- Notification permission: requested **only when the customer enables appointment reminders**
- Appointment reminders: **local notifications only** (24-hour and 1-hour)
- Location permission: **optional, requested for an on-demand service-area check**. No background location tracking.
- Push Notifications entitlement: **not enabled**
- Associated Domains: **not enabled**
- Privacy manifest: `MosquitoNinja/PrivacyInfo.xcprivacy` is included in the target and declares `UserDefaults` required-reason API `CA92.1`.
- Public privacy policy URL: **https://njbugninja.com/privacy.html**

## App Privacy answers to reconcile in App Store Connect

The final App Store Connect answers should match the production build and public policy. For the current quote flow, use the conservative disclosures below for information a customer affirmatively sends to Mosquito Ninja through Apple's Messages composer:

- **Name** — linked to the user, not used for tracking, App Functionality.
- **Phone Number** — linked to the user, not used for tracking, App Functionality.
- **Coarse Location** — linked to the user, not used for tracking, App Functionality, representing the customer-supplied property town/ZIP in a sent quote.
- **Photos or Videos** — linked to the user, not used for tracking, App Functionality, only when the customer chooses property-photo attachments and sends them.
- **Other User Content** — linked to the user, not used for tracking, App Functionality, representing property notes/details the customer chooses to send.
- **Tracking** — No.

The app's optional iOS location check is processed on-device for county/ZIP service-area evaluation. Mosquito Ninja does not receive or store the precise coordinates from that location check, so do not describe the location permission itself as background tracking or server-side precise-location collection.

## Final release-candidate test

Before submission, install the exact TestFlight build that will be selected for review and test on a physical iPhone and iPad:

- Cold launch and warm launch, including the splash transition.
- Portrait and landscape where supported.
- iPad responsive header / hamburger menu.
- Dynamic Type and Reduce Motion.
- Call and Text actions.
- Quote validation, cancel, successful send, failed/unavailable messaging behavior, and optional photo attachments.
- Appointment add, edit, delete, relaunch persistence, and local history.
- 24-hour and 1-hour notification scheduling, including notification-denied behavior.
- Location Allow, Approximate Location, Deny, and unavailable-network fallback.
- Every native navigation destination and bundled reference page.
- External links and privacy-policy access.

Do not submit until the final build's App Privacy answers, privacy-policy URL, screenshots, age-rating answers and review notes have been checked against that exact binary.
