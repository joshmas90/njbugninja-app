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
if 'image="LaunchMark"' not in storyboard:
    errors.append('LaunchScreen.storyboard does not reference LaunchMark')
if 'constant="270"' not in storyboard:
    errors.append('LaunchScreen.storyboard does not contain the premium 270-point mark')
if errors:
    print('\n'.join(errors)); sys.exit(1)
print('PASS: bundled website references, asset metadata and splash assets verified.')
