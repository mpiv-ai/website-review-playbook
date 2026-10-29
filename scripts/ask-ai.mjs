// Asks an AI answer engine the same questions several times, with and without
// web search, and saves every answer. Needs OPENAI_API_KEY. Small cost: each
// web-search call uses roughly 10k tokens on gpt-4.1-mini.
// Usage: node scripts/ask-ai.mjs <questions.txt> <output-dir> [runs]
//   questions.txt: one question per line.
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join, resolve, relative, dirname, isAbsolute } from "node:path";
import { fileURLToPath } from "node:url";

const [qfile, outDir, runsArg = "3"] = process.argv.slice(2);
if (!qfile || !outDir) { console.error("usage: node scripts/ask-ai.mjs <questions.txt> <output-dir> [runs]"); process.exit(1); }
// Only read questions from, and write answers to, this repo's reviews/ or
// examples/ folders, so a stray argument can't send a local file to the API.
const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const inside = (p, ...dirs) => dirs.some((d) => { const r = relative(join(repo, d), resolve(p)); return r && !r.startsWith("..") && !isAbsolute(r); });
if (!inside(qfile, "reviews", "examples")) { console.error(`Questions file must be inside reviews/ or examples/: ${qfile}`); process.exit(2); }
if (!inside(outDir, "reviews")) { console.error(`Output folder must be inside reviews/: ${outDir}`); process.exit(2); }
if (!process.env.OPENAI_API_KEY) { console.error("Set OPENAI_API_KEY first (export OPENAI_API_KEY=...)."); process.exit(1); }

const model = process.env.AI_MODEL || "gpt-4.1-mini";
const runs = Number(runsArg);
if (!Number.isInteger(runs) || runs < 1 || runs > 10) { console.error(`runs must be a number from 1 to 10: ${runsArg}`); process.exit(2); }
const questions = readFileSync(qfile, "utf8").split("\n").map((s) => s.trim()).filter(Boolean);
mkdirSync(outDir, { recursive: true });

const ask = async (input, search) => {
  const res = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: `Bearer ${process.env.OPENAI_API_KEY}` },
    body: JSON.stringify({ model, input, ...(search ? { tools: [{ type: "web_search" }] } : {}) }),
  });
  const json = await res.json();
  if (!res.ok) throw new Error(`${res.status}: ${JSON.stringify(json).slice(0, 300)}`);
  return json;
};

const textOf = (json) => (json.output || []).flatMap((o) => o.content || []).filter((c) => c.type === "output_text").map((c) => c.text).join("\n");
const citesOf = (json) => (json.output || []).flatMap((o) => o.content || []).flatMap((c) => c.annotations || []).filter((a) => a.url).map((a) => a.url);

let summary = `# AI answers (${model}, ${runs} runs per question and mode, ${new Date().toISOString().slice(0, 10)})\n`;
for (const [qi, q] of questions.entries()) {
  summary += `\n## Q${qi + 1}: ${q}\n`;
  for (const search of [true, false]) {
    for (let r = 1; r <= runs; r++) {
      const tag = `q${qi + 1}-${search ? "web" : "noweb"}-${r}`;
      try {
        const json = await ask(q, search);
        writeFileSync(join(outDir, `${tag}.json`), JSON.stringify(json, null, 2));
        const cites = [...new Set(citesOf(json))].slice(0, 6);
        summary += `\n### ${search ? "with web search" : "no web search"}, run ${r}\n${textOf(json).slice(0, 1500)}\n${cites.length ? "\nCited: " + cites.join(", ") + "\n" : ""}`;
        console.log(`${tag}: ok`);
      } catch (e) {
        summary += `\n### ${tag}: ERROR ${e.message}\n`;
        console.log(`${tag}: ${e.message}`);
      }
    }
  }
}
writeFileSync(join(outDir, "answers.md"), summary);
console.log(`Saved ${join(outDir, "answers.md")}`);
