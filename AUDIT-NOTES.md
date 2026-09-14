# App audit and independent update

Baseline: `be791f273bb1c59fff9ad8e9c0f7ef3fb95412b8` in `joshmas90/njbugninja-app`.

Evidence: the current Swift/Xcode project, bundled reference content, existing brand assets, and source checks. Xcode compilation, device interaction and layout verification remain required.

| Section / feature | Stronger starting point | Decision |
| --- | --- | --- |
| Brand introduction and service storytelling | Website | Preserve the web hero and editorial sections; adapt its clearer service explanation to native app cards. |
| Quick customer actions | App | Preserve native tabs/actions; provide Call and Quote together in the website's mobile action bar. |
| Quote handling | App | Preserve one in-app MessageUI sheet; bring required contact validation and contextual service selection to the website, with truthful browser handoff/copy states. |
| Coverage checking | App | Keep its optional location check; add a manual county/ZIP check on the website using the existing configured territory. |
| Before/after-service guidance | App | Make its guide easier to find in the app and create a separate printable/checkable web guide. |
| Public discovery, link sharing and service depth | Website | Retain crawlable HTML, metadata and internal links; give app customers that depth through native detail screens. |
| Local appointments and reminders | App | Retain on-device appointments/notifications as native features. A browser appointment system would require a separate product/backend decision. |

## What was strongest in the app

Native navigation, direct actions, local appointment/reminder tools, optional location-based route checking, and the recently improved in-app message composer support repeat customer use. The practical service-preparation guide is more useful than the website's scattered preparation references.

## What this app update improves

1. Mosquito, tick and commercial/government services now have dedicated native detail screens. Their focus areas, service process, expectations and property prompts adapt the website's stronger explanations into app-owned Swift. Home, Services and links from reference pages route there.
2. Request this service carries the selected service into Quote. Existing contact and property fields stay intact.
3. Services and service details provide direct access to the preparation guide.
4. Native body/headline/card text supports Dynamic Type so the richer content can follow the customer's text-size setting.
5. Replaced customer-facing technical implementation copy with useful owner/contact guidance and corrected outdated location-permission statements in release documentation.

## Identity and separation

The app remains a UIKit/Xcode project in its own repository. The existing hero artwork, tab structure, appointments, notification code, service-area manager and MessageUI implementation were preserved. No website source, build, UI package or new backend is imported. Existing bundled reference content remains app-owned. The pre-existing public county/ZIP rule feed remains unchanged; it is a data feed, not a combined codebase.

## Checks and release limits

- All 16 Swift files passed syntax parsing.
- The Xcode project parses and includes every Swift source exactly once.
- Bundled content/asset checks and whitespace checks passed.
- Appointment, notification, coverage-manager and messaging implementation files were compared against the baseline and remain unchanged.
- Native compilation and real iPhone/iPad testing were unavailable. Verify service navigation/back behavior, large text, preselection with a partially completed quote, prep navigation and MessageUI before release.

## Upload from an extracted folder

Run `SHIP-TO-GITHUB.cmd` inside a fresh extraction. It establishes this package's baseline, commits the update, rebases onto current GitHub main and pushes to the APP repository. It stops on errors and does not force-push. If the folder already has Git metadata, it stops so an existing checkout cannot be reset accidentally. Building/testing the app remains a separate release step.
