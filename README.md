# Mosquito Ninja — iOS app

A native UIKit shell around the approved njbugninja.com V21 site. The site is bundled inside the app, so primary content is not dependent on the live website being available.

## Native iOS additions

- Native bottom actions for **Quote**, **Call**, and **Text**.
- `tel:`, `sms:`, and `mailto:` links open the appropriate iOS app.
- External web links open outside the app; Mosquito Ninja website links stay inside the bundled app.
- Swipe-back/forward navigation is enabled.
- iPhone and iPad support, iOS 15+.
- Native app icon and launch screen generated from the existing Mosquito Ninja mark.
- No Push Notifications, Associated Domains, location, camera, microphone, or other protected capabilities are requested.

## Open in Xcode

1. Copy this folder to a Mac.
2. Open `MosquitoNinja.xcodeproj`.
3. Select the **MosquitoNinja** target → **Signing & Capabilities**.
4. Choose your Apple Developer Team.
5. Keep `com.njbugninja.app` if it is available to your account, or change the bundle identifier to one you control.
6. Select an iPhone/iPad or simulator and Run.

For App Store distribution: **Product → Archive → Distribute App → App Store Connect**.

## Important App Store note

Apple's minimum-functionality review can reject apps that are only thin website wrappers. This project intentionally adds a native service-action layer and bundles the content locally, but App Review is never guaranteed. Adding account-specific service history, appointment management, push-free local reminders, or other genuinely app-specific customer features later would strengthen the submission further.

## Updating website content later

Replace the contents of `MosquitoNinja/Web/` with an app-adjusted export of the site. Root-relative website links (`/assets/...`, `/faq.html`, etc.) must remain bundle-relative (`./assets/...`, `./faq.html`) for offline loading.

## Verify

On any machine with Python:

```bash
python3 scripts/verify_bundle.py
```

On a Mac with Xcode:

```bash
./scripts/build-simulator.sh
```
