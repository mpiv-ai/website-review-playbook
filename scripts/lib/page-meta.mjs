// Prints SEO and structure facts for every saved page in a folder.
// Usage: node page-meta.mjs <pages-dir>
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

const dir = process.argv[2];
const strip = (s) => s.replace(/<[^>]+>/g, " ").replace(/&amp;/g, "&").replace(/&#39;|&rsquo;/g, "'").replace(/\s+/g, " ").trim();
const first = (re, s) => (s.match(re) || [, ""])[1];

for (const f of readdirSync(dir).filter((f) => f.endsWith(".html")).sort()) {
  const s = readFileSync(join(dir, f), "utf8");
  const body = s.replace(/<script[\s\S]*?<\/script>|<style[\s\S]*?<\/style>/gi, " ");
  const headings = [...s.matchAll(/<(h[1-6])[^>]*>([\s\S]*?)<\/\1>/gi)].map(([, t, x]) => `${t.toLowerCase()}: ${strip(x).slice(0, 90)}`);
  const imgs = [...s.matchAll(/<img\b[^>]*>/gi)].map((m) => m[0]);
  const jsonld = [...s.matchAll(/<script[^>]+application\/ld\+json[^>]*>([\s\S]*?)<\/script>/gi)].map((m) => first(/"@type"\s*:\s*"([^"]+)"/, m[1]));
  console.log(`===== ${f}`);
  console.log(`title: ${strip(first(/<title[^>]*>([\s\S]*?)<\/title>/i, s))}`);
  console.log(`meta description: ${first(/<meta[^>]+name="description"[^>]+content="([^"]*)"/i, s) || "(none)"}`);
  console.log(`canonical: ${first(/<link[^>]+rel="canonical"[^>]+href="([^"]*)"/i, s) || "(none)"}`);
  console.log(`og:title: ${first(/<meta[^>]+property="og:title"[^>]+content="([^"]*)"/i, s) || "(none)"}`);
  console.log(`json-ld blocks: ${jsonld.length}${jsonld.length ? " (" + jsonld.join(", ") + ")" : ""}`);
  console.log(`h1 count: ${headings.filter((h) => h.startsWith("h1")).length}`);
  console.log(`images: ${imgs.length}, missing alt attribute: ${imgs.filter((i) => !/\balt=/i.test(i)).length}, empty alt: ${imgs.filter((i) => /\balt=""/i.test(i)).length}`);
  console.log(`words (approx): ${strip(body).split(" ").length}`);
  console.log(`prices mentioned: ${[...new Set(strip(body).match(/\$\s?\d[\d,]*(\.\d+)?\s?(k|K)?/g) || [])].slice(0, 15).join(" ") || "(none)"}`);
  console.log("headings:\n  " + headings.slice(0, 40).join("\n  "));
}
