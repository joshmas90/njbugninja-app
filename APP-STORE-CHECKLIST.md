# App Store setup checklist

- App name: **Mosquito Ninja**
- Version: **1.0**
- Build: **1**
- Default bundle identifier in project: `com.njbugninja.app`
- Minimum iOS: **15.0**
- Devices: **iPhone + iPad**
- Encryption declaration: non-exempt encryption = **No**
- Notification permission: requested **only when the customer enables appointment reminders**
- Appointment reminders: **local notifications only** (24-hour and 1-hour)
- Location permission: **optional, requested for an on-demand service-area check**. No background location tracking; review the existing iOS geocoding and public rule downloads in App Privacy answers.
- Push Notifications entitlement: **not enabled**
- Associated Domains: **not enabled**

Before submission, test Call, Text, quote flow, appointment add/edit/delete, 24-hour and 1-hour notification scheduling, notification-denied behavior, every navigation page, rotation, iPad layout, and external links on a physical device. Review the App Privacy answers against the final production build. The appointment feature stores appointment details on-device and uses local iOS notifications; it does not use location tracking or server-side appointment storage in this build.
