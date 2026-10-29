// Lists same-site page paths linked from a saved homepage, one per line.
// Usage: node discover-pages.mjs <domain> <homepage.html> [max]
import { readFileSync } from "node:fs";

const [domain, file, max = "25"] = process.argv.slice(2);
const html = readFileSync(file, "utf8");
const skip = /\.(css|js|png|jpe?g|gif|svg|webp|ico|woff2?|pdf|xml|txt|json)$/i;
const paths = new Set(["/"]);

for (const [, href] of html.matchAll(/href="([^"]+)"/g)) {
  let url;
  try { url = new URL(href, `https://${domain}/`); } catch { continue; }
  const host = url.hostname.replace(/^www\./, "");
  if (host !== domain.replace(/^www\./, "") || !/^https?:$/.test(url.protocol)) continue;
  if (skip.test(url.pathname)) continue;
  paths.add(url.pathname.replace(/\/+$/, "") || "/");
}

console.log([...paths].slice(0, Number(max)).join("\n"));
