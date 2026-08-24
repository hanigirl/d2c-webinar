# Serving this site at uxtra.co.il/lives/design-to-code/

GitHub Pages attaches a custom domain to a **host** (`uxtra.co.il`,
`lives.uxtra.co.il`), never to a **path**. Adding a `CNAME` file to this repo
therefore cannot produce `uxtra.co.il/lives/design-to-code` — it would take over
the whole apex and knock out the main site.

Cloudflare already sits in front of `uxtra.co.il`, so the path is produced there
instead. `worker.js` proxies that one prefix to this repo's Pages deployment and
leaves every other request alone.

## Setup, once

1. Cloudflare dashboard → **Workers & Pages** → **Create** → **Worker**.
   Name it `d2c-webinar`, deploy the default, then **Edit code**, paste
   `worker.js`, and deploy.
2. Open the Worker → **Settings** → **Domains & Routes** → **Add route**:
   - Route: `uxtra.co.il/lives/design-to-code*`
   - Zone: `uxtra.co.il`
3. Add the same route for `www.uxtra.co.il/lives/design-to-code*` if `www`
   serves the site too.

Leave this repo's Pages settings on the default `hanigirl.github.io` domain —
the Worker fetches from there, so pointing Pages at a custom domain would break
the origin it reads.

## After changing the path

`PREFIX` in `worker.js` and the `canonical` / `og:url` / `og:image` tags at the
top of `index.html` all name the public URL. Change them together.
