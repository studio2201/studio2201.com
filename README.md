# studio2201.com — Official Studio 2201 Portal & Storefront

[![CI](https://github.com/studio2201/studio2201.com/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/studio2201/studio2201.com/actions/workflows/ci.yml)
[![Release](https://img.shields.io/badge/version-v0.5.0-blue.svg)](https://github.com/studio2201/studio2201.com/releases)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Max LOC](https://img.shields.io/badge/max%20LOC-%E2%89%A4256-brightgreen.svg)](https://studio2201.com)
[![Sponsor: Tuition, Not Coffee](https://img.shields.io/badge/Sponsor-Tuition%2C%20Not%20Coffee%20%F0%9F%8E%93-2ec27e)](https://ubermetroid.github.io/tuition-not-coffee)

The static source for [**studio2201.com**](https://studio2201.com) — showcasing all three engineering pillars of **Studio 2201**:

1. **01 · GNOME Shell Desktop Suite (Wayland 45–50)**:
   - [**Kelp**](https://studio2201.github.io/kelp/) (`kelp@studio2201.github.io`) — Octopus 2D Grid, Seahorse Scroller, and Otter Floating Auto-Tiler (`v2.2.0`)
   - [**Reef**](https://studio2201.github.io/reef/) (`reef@studio2201.github.io`) — Intelligent Wayland Dock & Panel with Pressure Barriers (`v1.2.0`)
   - [**Tide**](https://studio2201.github.io/tide/) (`tide@studio2201.github.io`) — Super & `Super+Enter` Application & Open-Window Launcher (`v1.2.1`)
   - [**Coral**](https://studio2201.github.io/coral/) (`coral@studio2201.github.io`) — Alphabetical App Grid & Smart Auto-Folder Organizer (`v1.4.0`)
   - [**Seabed**](https://studio2201.github.io/seabed/) (`seabed@studio2201.github.io`) — Compositor-Native Desktop Icons & Drag-and-Drop (`v1.5.0`)
   - [**Shoal**](https://studio2201.github.io/shoal/) (`shoal@studio2201.github.io`) — AppIndicator, SNI & DBusMenu Top-Bar System Tray (`v1.2.0`)
2. **02 · GitHub CI/CD Actions & Supply-Chain Security (Pure `std::` Rust)**:
   - [**Vigil**](https://studio2201.com/vigil) (`studio2201/vigil`) — Dependency dormancy & abandonment scanner
   - [**Snip**](https://studio2201.com/snip) (`studio2201/snip`) — Vibe-code diff gate for secrets, PII & RLS
   - [**Aegis**](https://studio2201.com/aegis) (`studio2201/aegis`) — Post-Quantum Cryptography (OMB M-26-15) migration scanner
   - [**Proven**](https://studio2201.com/proven) (`studio2201/proven`) — FIPS 204 ML-DSA-65 reproducible binary attestor
   - [**Boneyard**](https://studio2201.com/boneyard) (`studio2201/boneyard`) — Org-wide repository tech-debt radar
   - [**CLI**](https://github.com/studio2201/cli) & [**Canary**](https://studio2201.com/canary) — Unified workstation driver & negative verification testbed
3. **03 · Webpages, Microsites & Interactive Guides**:
   - Zero-framework semantic HTML/CSS portals strictly enforcing the **&le; 256 LOC Page Rule**.

## Local Preview

```sh
python3 -m http.server 8000
# open http://localhost:8000
```

## Structure

```
studio2201.com/
├── index.html        # Multi-pillar showcase: GNOME Suite, CI/CD Actions, Webpages & Doctrine
├── agents.html       # Agent & Automation Guide (MCP, Cursor, CI/CD)
├── canary.html       # Canary reference failure showcase
├── vigil.html        # Vigil product page
├── snip.html         # Snip product page
├── boneyard.html     # Boneyard product page
├── aegis.html        # Aegis product page
├── proven.html       # Proven product page
├── 404.html          # Clean 404 error page
├── styles.css        # Base typography, layout, variables (<= 256 LOC)
├── components.css    # Sticky nav, responsive multi-pillar cards, badges (<= 256 LOC)
├── install.sh        # Universal installer script (<= 256 LOC)
├── sitemap.xml       # Search engine sitemap
├── CNAME             # Custom domain studio2201.com
└── VERSION           # Release version tracking (0.5.0)
```

## License

Apache-2.0. See [`LICENSE`](LICENSE). © 2026 studio2201.
