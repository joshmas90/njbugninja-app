# Throwing-star launch screen

The iOS launch screen now uses the existing throwing-star logo from the app's bundled artwork. The original WebP was converted losslessly to PNG for the asset catalog; the design was not regenerated or altered.

The launch mark remains centered at 150 by 150 points with aspect-fit sizing on the existing dark background. No animation or artificial launch delay was added.

The home-screen app icon now uses the same throwing-star artwork, exported as an opaque 1024 by 1024 PNG. The available bundled logo is 256 by 256 pixels, so the icon is upscaled from that source rather than recreated. The website and app functionality are unchanged.

This package includes the previous strengths update and in-app messaging changes, based on app main commit 8718424aa9790dc89f078865bc1c111a24f78db1.

## Upload and check

Run SHIP-TO-GITHUB.cmd from a fresh extraction to upload only to joshmas90/njbugninja-app. The script stops on errors and never force-pushes.

Build the updated app and check its home-screen icon and a cold launch on iPhone and iPad. Static asset and storyboard checks were performed, but Xcode compilation and on-device launch testing were not available in this workspace. No build or deployment was triggered.
