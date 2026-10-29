// Summarizes repeated Lighthouse JSON runs: each run, then the median per device.
// Usage: node lighthouse-summary.mjs <folder-with-mobile-N.json-and-desktop-N.json>
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

const dir = process.argv[2];
const median = (xs) => { const s = [...xs].sort((a, b) => a - b); const m = s.length >> 1; return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2; };
const fmt = (r) => `score ${r.score}  FCP ${r.fcp.toFixed(1)}s  LCP ${r.lcp.toFixed(1)}s  TBT ${Math.round(r.tbt)}ms  CLS ${r.cls.toFixed(2)}  weight ${Math.round(r.kb)}KB  requests ${r.req}`;

for (const device of ["mobile", "desktop"]) {
  const runs = readdirSync(dir).filter((f) => f.startsWith(device) && f.endsWith(".json")).sort().map((f) => {
    const lh = JSON.parse(readFileSync(join(dir, f), "utf8"));
    const a = lh.audits;
    return {
      f, score: Math.round(lh.categories.performance.score * 100),
      fcp: a["first-contentful-paint"].numericValue / 1000, lcp: a["largest-contentful-paint"].numericValue / 1000,
      tbt: a["total-blocking-time"].numericValue, cls: a["cumulative-layout-shift"].numericValue,
      kb: a["total-byte-weight"].numericValue / 1024, req: a["network-requests"]?.details?.items?.length ?? 0,
    };
  });
  if (!runs.length) continue;
  console.log(`== ${device} (${runs.length} runs)`);
  for (const r of runs) console.log(`  ${r.f}: ${fmt(r)}`);
  const m = Object.fromEntries(Object.keys(runs[0]).filter((k) => k !== "f").map((k) => [k, median(runs.map((r) => r[k]))]));
  console.log(`  MEDIAN: ${fmt(m)}`);
  console.log(`  LCP range: ${Math.min(...runs.map((r) => r.lcp)).toFixed(1)}s to ${Math.max(...runs.map((r) => r.lcp)).toFixed(1)}s`);
}
console.log("Google 'good' thresholds: LCP under 2.5s, CLS under 0.1, TBT under 200ms. 'Poor': LCP over 4.0s, CLS over 0.25.");
