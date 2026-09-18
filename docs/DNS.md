# DNS + GitHub Pages setup for studio2201.com

Two-step process. **Step 1 is at your domain registrar** (where you bought the domain). **Step 2 is on GitHub**.

## At your registrar

You need one set of `A` records at the apex. The `www` subdomain is handled by GitHub automatically once the apex is set up — you do **not** need a `www` CNAME record pointing at any GitHub Pages URL.

### Apex (the bare `studio2201.com`)

GitHub Pages publishes the IPs that the apex should point at. As of 2025–2026 these are:

```
A  @
    185.199.108.153
A  @
    185.199.109.153
A  @
    185.199.110.153
A  @
    185.199.111.153
```

That's four `A` records all with the host field set to `@` (or blank, depending on your registrar). Some registrars call this "apex" or "root."

If your registrar supports `ALIAS` or `ANAME` records at the apex, set one of:

```
ALIAS  @  github.map.fastly.net.
ANAME  @  github.map.fastly.net.
```

This is cleaner than the four A records because GitHub can move the IPs without breaking you. Cloudflare Registrar and a few others support this. If yours doesn't, use the four A records.

### www subdomain

**Do not add a CNAME record for `www`.** GitHub Pages automatically redirects `www.studio2201.com` to the apex (`studio2201.com`) once the CNAME file in the `studio2201/studio2201.com` repo is set. Adding a `www` CNAME pointing at any GitHub Pages URL is the legacy approach and is unnecessary under current GitHub Pages.

If you previously had a `www` CNAME pointing at `studio2201.github.io`, **delete it** — it served the now-deprecated `studio2201/studio2201.github.io` org user page, which has been retired in favor of `studio2201/studio2201.com`.

## On GitHub

In the `studio2201/studio2201.com` repository:

1. **Settings → Pages** (left sidebar).
2. **Source**: `Deploy from a branch`.
3. **Branch**: `master` / `(root)`. (Both product repos and the website will all be on `master`. Pages picks the one with the `CNAME` file.)
4. **Custom domain**: enter `studio2201.com`. Click Save.
5. Wait ~1 minute for GitHub to do DNS checks. A green "DNS check successful" appears.
6. Toggle **Enforce HTTPS** once GitHub has provisioned the Let's Encrypt cert (a few minutes).

## Troubleshooting

- **"DNS check in progress" forever**: usually means the `CNAME` file in this repo (`studio2201.com`) doesn't match the apex. They must agree.
- **"Improperly configured"**: GitHub will tell you which record is missing. Usually the apex A records.
- **HTTPS not available**: GitHub hasn't validated the apex A records yet. Wait a few hours.
- **`www.studio2201.com` not redirecting**: confirm you have **no** `www` CNAME at your registrar; GitHub handles the redirect itself.

## What "working" looks like

After both steps:

- `https://studio2201.com/` — the site
- `https://www.studio2201.com/` — auto-redirects to the apex
- `http://studio2201.com/` — auto-redirects to https
- GitHub Pages panel shows "Your site is live at https://studio2201.com"

Takes ~10 minutes end-to-end once the registrar propagates.

## DNS for `opensource@studio2201.com` (optional)

If you also want email at your domain, that's a separate MX + SPF + DKIM setup at the registrar. Recommend a hosted email service (Fastmail, ProtonMail, Zoho Mail, Google Workspace). Easy 30-min setup, separate from this page.

**Your DNS at a glance (typical setup):**

| Type | Host | Value | TTL |
|---|---|---|---|
| A | @ | 185.199.108.153 | 600 |
| A | @ | 185.199.109.153 | 600 |
| A | @ | 185.199.110.153 | 600 |
| A | @ | 185.199.111.153 | 600 |
