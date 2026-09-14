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
json.load(open(root/'MosquitoNinja'/'Assets.xcassets'/'AppIcon.appiconset'/'Contents.json'))
if errors:
    print('\n'.join(errors)); sys.exit(1)
print('PASS: bundled website references and asset metadata verified.')
