#!/usr/bin/env python3
from pathlib import Path
import re, json, plistlib, sys
root = Path(__file__).resolve().parents[1]
web = root/'MosquitoNinja'/'Web'
errors=[]

required_web_pages = [
    web/'index.html',
    web/'mosquito-control.html',
    web/'tick-control.html',
    web/'fly-control.html',
    web/'commercial.html',
    web/'service-area.html',
    web/'faq.html',
]
for page in required_web_pages:
    if not page.exists():
        errors.append(f'missing bundled service page: {page.relative_to(root)}')

for p in web.glob('*.html'):
    text=p.read_text(encoding='utf-8')
# More robust attribute extraction
for p in web.glob('*.html'):
    text=p.read_text(encoding='utf-8')
    for target in re.findall(r'(?:href|src)=["\']([^"\']+)["\']', text):
        if target.startswith(('./','../')):
            clean=target.split('#',1)[0].split('?',1)[0]
            q=(p.parent/clean).resolve()
            if not q.exists(): errors.append(f'{p.name}: missing {target}')
for p in web.glob('*.css'):
    for target in re.findall(r'url\(["\']?([^"\')]+)',p.read_text(encoding='utf-8')):
        if target.startswith('./'):
            q=(p.parent/target).resolve()
            if not q.exists(): errors.append(f'{p.name}: missing {target}')
assets = root/'MosquitoNinja'/'Assets.xcassets'
for metadata in assets.rglob('Contents.json'):
    json.load(open(metadata, encoding='utf-8'))

required_splash_assets = [
    assets/'LaunchMark.imageset'/'LaunchMark.png',
    assets/'SplashWordmark.imageset'/'SplashWordmark.png',
]
for asset in required_splash_assets:
    if not asset.exists() or asset.stat().st_size == 0:
        errors.append(f'missing splash asset: {asset.relative_to(root)}')

storyboard = (root/'MosquitoNinja'/'LaunchScreen.storyboard').read_text(encoding='utf-8')
if 'image="LaunchMark"' in storyboard or '<imageView' in storyboard:
    errors.append('LaunchScreen.storyboard must remain artwork-free for a clean black handoff')
if 'red="0.008" green="0.016" blue="0.012"' not in storyboard:
    errors.append('LaunchScreen.storyboard does not use the required launch-black background')

app_delegate = (root/'MosquitoNinja'/'AppDelegate.swift').read_text(encoding='utf-8')
overlay_mount = app_delegate.find('window.addSubview(launchOverlay)')
window_reveal = app_delegate.find('window.makeKeyAndVisible()')
if overlay_mount == -1 or window_reveal == -1 or overlay_mount > window_reveal:
    errors.append('native launch overlay must mount before the app window becomes visible')

active_callback = app_delegate.find('func applicationDidBecomeActive')
overlay_front = app_delegate.find('window.bringSubviewToFront(launchOverlay)', active_callback)
deferred_playback = app_delegate.find('DispatchQueue.main.async', active_callback)
overlay_playback = app_delegate.find('launchOverlay.play()', deferred_playback)
if (
    active_callback == -1
    or overlay_front == -1
    or deferred_playback == -1
    or overlay_playback == -1
    or not window_reveal < active_callback < overlay_front < deferred_playback < overlay_playback
):
    errors.append('native launch overlay playback must wait for applicationDidBecomeActive')
if 'accessibilityIdentifier="mosquito-ninja-launch-overlay"' not in app_delegate:
    errors.append('native launch overlay is missing its UI-test accessibility identifier')

root_tabs = (root/'MosquitoNinja'/'RootTabBarController.swift').read_text(encoding='utf-8')
if '("Fly Control", "ant.fill", 5)' not in root_tabs:
    errors.append('Fly Control header navigation is missing')
if 'ServiceDetailViewController(service: .fly)' not in root_tabs:
    errors.append('Fly Control header navigation is not wired to the native service detail')

home = (root/'MosquitoNinja'/'HomeViewController.swift').read_text(encoding='utf-8')
for marker in (
    'spring-ember',
    'spring-edge-sweep',
    'spring-energy-sweep',
    'spring-rim-pulse',
    'isReduceMotionEnabled',
):
    if marker not in home:
        errors.append(f'missing native Spring CTA motion safeguard: {marker}')
if 'action: #selector(openSpringQuote)' not in home or 'for: .touchUpInside' not in home:
    errors.append('Spring CTA card is missing its full-card quote action')

# Guard the My Service dashboard against the layout regression that can shrink
# the entire phone page to the width of its 1-point summary divider.
appointment = (root/'MosquitoNinja'/'Appointment.swift').read_text(encoding='utf-8')
summary_start = appointment.find('private func summaryPanel()')
summary_end = appointment.find('private func metric(', summary_start)
summary_block = appointment[summary_start:summary_end] if summary_start != -1 and summary_end != -1 else ''
if 'row.distribution = .fillEqually' in summary_block:
    errors.append('My Service summary must not use fillEqually with its fixed-width divider')
if 'upcoming.widthAnchor.constraint(equalTo: previous.widthAnchor)' not in summary_block:
    errors.append('My Service summary metrics must keep equal widths explicitly')

# On phones the shared content column must stay effectively full-width. The
# 1120-point required maximum is allowed to override this only on wide iPads.
native_ui = (root/'MosquitoNinja'/'NativeUI.swift').read_text(encoding='utf-8')
if 'preferredWidth.priority = UILayoutPriority(999)' not in native_ui:
    errors.append('shared content width priority must remain 999 to prevent page collapse')

# Apple privacy-manifest checks. The app uses UserDefaults for on-device
# appointments and collects only customer-supplied quote data when the customer
# affirmatively sends a message to Mosquito Ninja.
privacy_path = root/'MosquitoNinja'/'PrivacyInfo.xcprivacy'
if not privacy_path.exists():
    errors.append('missing MosquitoNinja/PrivacyInfo.xcprivacy')
else:
    try:
        with privacy_path.open('rb') as handle:
            privacy = plistlib.load(handle)
    except Exception as exc:
        errors.append(f'invalid PrivacyInfo.xcprivacy: {exc}')
        privacy = {}

    if privacy.get('NSPrivacyTracking') is not False:
        errors.append('privacy manifest must declare tracking disabled')

    accessed = {
        item.get('NSPrivacyAccessedAPIType'): set(item.get('NSPrivacyAccessedAPITypeReasons', []))
        for item in privacy.get('NSPrivacyAccessedAPITypes', [])
        if isinstance(item, dict)
    }
    if 'CA92.1' not in accessed.get('NSPrivacyAccessedAPICategoryUserDefaults', set()):
        errors.append('privacy manifest must declare UserDefaults reason CA92.1')

    collected = {
        item.get('NSPrivacyCollectedDataType')
        for item in privacy.get('NSPrivacyCollectedDataTypes', [])
        if isinstance(item, dict)
    }
    required_collected = {
        'NSPrivacyCollectedDataTypeName',
        'NSPrivacyCollectedDataTypePhoneNumber',
        'NSPrivacyCollectedDataTypeCoarseLocation',
        'NSPrivacyCollectedDataTypePhotosorVideos',
        'NSPrivacyCollectedDataTypeOtherUserContent',
    }
    missing_collected = sorted(required_collected - collected)
    if missing_collected:
        errors.append('privacy manifest missing collected data types: ' + ', '.join(missing_collected))

project = (root/'MosquitoNinja.xcodeproj'/'project.pbxproj').read_text(encoding='utf-8')
if 'PrivacyInfo.xcprivacy in Resources' not in project:
    errors.append('PrivacyInfo.xcprivacy is not included in the app target resources')

if errors:
    print('\n'.join(errors)); sys.exit(1)
print('PASS: bundled website references, asset metadata, splash assets and privacy manifest verified.')
