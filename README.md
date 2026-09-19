# studio2201.com — Site Source

[![CI](https://github.com/studio2201/studio2201.com/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/studio2201/studio2201.com/actions/workflows/ci.yml)
[![Release](https://img.shields.io/badge/version-v0.4.24-blue.svg)](https://github.com/studio2201/studio2201.com/releases)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Max LOC](https://img.shields.io/badge/max%20LOC-%E2%89%A4256-brightgreen.svg)](https://studio2201.com)

The static source for [studio2201.com](https://studio2201.com). Hosted via GitHub Pages.

## Local Preview

```sh
# Any static-file server works. Python's is built-in:
python3 -m http.server 8000
# open http://localhost:8000
```

## Structure

```
studio2201.com/
├── index.html        # Homepage with product showcase & agent guide overview
├── agents.html       # Agent & Automation Guide (MCP, Cursor, CI/CD)
├── canary.html       # Canary reference failure showcase
├── vigil.html        # Vigil product page
├── snip.html         # Snip product page
├── boneyard.html     # Boneyard product page
├── aegis.html        # Aegis product page
├── proven.html       # Proven product page
├── 404.html          # Clean 404 error page
├── styles.css        # Base typography, layout, variables (<= 256 LOC)
├── components.css    # Reusable UI cards, buttons, badges (<= 256 LOC)
├── install.sh        # Universal installer script (<= 256 LOC)
├── sitemap.xml       # Search engine sitemap
├── CNAME             # Tells GitHub Pages to serve studio2201.com
├── .nojekyll         # Skip Jekyll processing on GitHub Pages
├── assets/           # Brand assets and icons
├── docs/             # Technical docs (DNS.md)
├── VERSION           # Release version tracking
└── README.md
```

## Deployment

1. Push changes to `master` on GitHub.
2. GitHub Pages: Settings → Pages → Source: `Deploy from a branch` → `master` / `(root)`.
3. Custom domain: `studio2201.com`. Enforce HTTPS.

## License

Apache-2.0. See `LICENSE`.

© 2026 studio2201.
