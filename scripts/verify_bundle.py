#!/usr/bin/env python3
from pathlib import Path
import re, json, sys
root = Path(__file__).resolve().parents[1]
web = root/'MosquitoNinja'/'Web'
errors=[]
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
if errors:
    print('\n'.join(errors)); sys.exit(1)
print('PASS: bundled website references, asset metadata and splash assets verified.')
