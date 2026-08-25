/**
 * Serves this GitHub Pages site at uxtra.co.il/lives/design-to-code/
 *
 * GitHub Pages can only attach a custom domain at the host level, never at a
 * sub-path, so the path is produced here instead: Cloudflare already fronts
 * uxtra.co.il, and this Worker proxies the one prefix through to Pages while
 * every other path carries on to the normal origin.
 */

const UPSTREAM = 'https://hanigirl.github.io/d2c-webinar/';
const PREFIX = '/lives/design-to-code';

export default {
  async fetch(request) {
    const url = new URL(request.url);

    if (!url.pathname.startsWith(PREFIX)) {
      return fetch(request);
    }

    // Every asset on the page is referenced relatively, and relative URLs only
    // resolve correctly from a directory. Without the trailing slash the
    // browser would look for /lives/assets/… and the page would load bare.
    if (url.pathname === PREFIX) {
      return Response.redirect(`${url.origin}${PREFIX}/${url.search}`, 301);
    }

    const rest = url.pathname.slice(PREFIX.length + 1);
    const target = new URL(rest, UPSTREAM);
    target.search = url.search;

    const upstream = await fetch(target.toString(), {
      method: request.method,
      headers: { 'accept': request.headers.get('accept') || '*/*' },
      redirect: 'follow',
      // Never hold on to an error. A URL requested in the window between a
      // push and the Pages deploy answers 404, and caching that pins the miss
      // in place long after the file is live — which is how a link preview
      // ends up permanently blank.
      cf: { cacheTtlByStatus: { '200-299': 3600, '404': 0, '500-599': 0 } },
    });

    const response = new Response(upstream.body, upstream);
    // Pages' own headers describe the wrong host; drop the ones that leak it.
    response.headers.delete('x-github-request-id');
    response.headers.delete('server');
    return response;
  },
};
