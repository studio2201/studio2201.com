# studio2201.com — site source

The static source for [studio2201.com](https://studio2201.com). Hosted via GitHub Pages.

## Local preview

```sh
# Any static-file server works. Python's is built-in:
python3 -m http.server 8000
# open http://localhost:8000
```

## Structure

```
studio2201.com/
├── index.html        # The single page
├── styles.css        # Warm-cream report aesthetic (no framework)
├── CNAME             # Tells GitHub Pages to serve studio2201.com
├── .nojekyll         # Skip Jekyll processing on GitHub Pages
├── assets/
│   └── favicon.svg   # (placeholder — drop in real icon before launch)
├── docs/
│   └── DNS.md        # DNS + GitHub Pages setup notes
├── VERSION           # Release version tracking
└── README.md
```

## Deploy

1. Push to `main` on GitHub.
2. GitHub Pages: Settings → Pages → Source: `Deploy from a branch` → `main` / `(root)`.
3. Custom domain: enter `studio2201.com`. Wait for DNS check to succeed.
4. Enforce HTTPS in the same panel once the cert provisions.

See `docs/DNS.md` for the DNS records required at your registrar.

## License

Apache-2.0. See `LICENSE` (Apache-2.0 standard text).

© 2026 studio2201.
