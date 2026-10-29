# What this playbook doesn't do

Put the relevant lines in each report's "Method and limits" section so the reader knows what wasn't checked.

**Deliberately out of scope**

- Active security testing of any kind: port scans, vulnerability scans, login or form testing, load tests. That needs a signed authorization and a different method.
- Submitting forms, booking calls, downloading gated content, or contacting anyone.

**Not covered without paid tools or the owner's accounts**

- Keyword search volume and difficulty, backlink profiles, and rank tracking. Keyword suggestions in the report are judgment, not measured demand.
- Google Search Console and analytics data: real search queries, indexed page counts, and visitor numbers. Ask the owner for access if these matter.
- Real-visitor speed data (Chrome UX Report). New or small sites usually have none. Lighthouse lab runs are used instead.

**Hard to test from a terminal**

- Perplexity, Google AI Overviews and AI Mode, Gemini, Microsoft Copilot, and the consumer ChatGPT and Claude apps. The playbook tests OpenAI's API with and without web search, which is related but not identical.
- LinkedIn company pages, Google Maps listings, and some state business registries, which block automated reads. Report them as "not verified," not "missing."
- Manual accessibility testing (keyboard-only navigation, screen readers). Lighthouse covers only automated checks.

**Known weak spots to watch**

- Researcher subagents can miss content that's on a page they didn't open. Cross-check their claims about the client's own site against your own evidence.
- Full-page screenshots can render scroll-animated sections as blank. Use viewport screenshots for anything you put in the report.
