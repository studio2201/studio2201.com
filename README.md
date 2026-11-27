# studio2201.com — Websites, Custom Tools & Real-World AI

[![CI](https://github.com/studio2201/studio2201.com/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/studio2201/studio2201.com/actions/workflows/ci.yml)
[![Release](https://img.shields.io/badge/version-v0.6.4-blue.svg)](https://github.com/studio2201/studio2201.com/releases)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Max LOC](https://img.shields.io/badge/max%20LOC-%E2%89%A4256-brightgreen.svg)](https://studio2201.com)

The static source for [**studio2201.com**](https://studio2201.com) — an independent engineering agency for creating websites, building custom tools, and connecting AI to physical hardware and real-world workflows.

## Pages & Structure

```
studio2201.com/
├── index.html          # Minimal agency storefront: services, selected work, contact form
├── web.html            # Websites, web services, migrations, and DNS/email
├── tools.html          # Custom tools, applications, OS/systems engineering, and audits
├── ai.html             # Real-World AI showcase: hardware telemetry & automated sentinels
├── infrastructure.html # Private cloud, multi-site NAS storage, and lab management
├── lab.html            # Open-Source Lab: Wayland GNOME suite, Rust CI/CD gates, doctrine
├── agents.html       # Agent & Automation Guide (MCP, Cursor, CI/CD)
├── vigil.html        # Vigil product page
├── snip.html         # Snip product page
├── boneyard.html     # Boneyard product page
├── aegis.html        # Aegis product page
├── proven.html       # Proven product page
├── 404.html          # Clean 404 error page
├── styles.css        # Base typography, layout, variables (<= 256 LOC)
├── components.css    # Shared cards, badges, buttons (<= 256 LOC)
├── agency.css        # Two-theme (Warm Light / Charcoal) agency layout & form (<= 256 LOC)
├── theme.js          # Warm Light / Neutral Charcoal theme toggle (<= 256 LOC)
├── contact.js        # Zero-dependency project inquiry & email copy handler (<= 256 LOC)
├── worker/           # Free Cloudflare Worker (/api/contact) sending via Email Routing
├── sitemap.xml       # Search engine sitemap
└── CNAME             # Custom domain studio2201.com
```

## Local Preview

```sh
python3 -m http.server 8000
# open http://localhost:8000
```

## License

Apache-2.0. See [`LICENSE`](LICENSE). © 2026 studio2201.
