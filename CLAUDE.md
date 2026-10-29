# Website review playbook: instructions for the agent

You are running a website review for a small professional-services business. The goal is a practical report the owner can act on: what works, what's costing them clients, and a ranked list of fixes, with evidence for every claim.

The person running you will usually start with `/review <domain>`. If they just paste a URL, treat it the same way.

## Rules that never bend

1. **Passive only.** Read public pages, DNS records, and HTTP responses. Never run port scans, vulnerability scanners, login attempts, or load tests. Never submit a form, book a meeting, start a chat, or sign up for anything. If the site owner didn't ask for the review, stop after step 0 and confirm the user has permission.
2. **Evidence for every claim.** Every finding in the report points to a saved file in `reviews/<domain>-<date>/evidence/` or a screenshot in `shots/`. If you can't show it, label it "not verified" or leave it out.
3. **No invented numbers.** Quote figures from tool output. Performance numbers come from at least 3 runs and are reported as a median. AI-answer findings come from at least 3 runs per question. A single sample is labeled as one.
4. **Quote competitors from raw HTML.** Web fetch tools summarize pages and can paraphrase. Before a competitor quote goes in the report, confirm it with `curl` and `grep` against the raw page.
5. **Draft, don't send.** You write the report and a summary email as files. You don't send email or publish anything.

## Step 0: intake (ask once, in one message)

Ask the user for anything you don't already know. Proceed with sensible defaults when they say "go":

- The website URL.
- Who the business serves and what it sells, in one or two sentences. (If unknown, infer it from the site and say so.)
- Two or three competitors they know of, if any.
- Whether they have the raw headers of an email sent from the business's domain. See `docs/email-headers.md`. This is the only reliable way to check DKIM.
- Whether `OPENAI_API_KEY` is set (`node -e "console.log(!!process.env.OPENAI_API_KEY)"`). Without it, skip the AI-answer runs and use web search only.

Create the run folder: `reviews/<domain>-<YYYY-MM-DD>/` with `evidence/` and `shots/` inside. Every path below is relative to it.

## Step 1: collect evidence (run these in parallel)

Start the two researcher subagents in the background first, so they work while you do the rest:

- **competitor-researcher** with the brief in `prompts/competitor-scan.md` (fill in the business description, URL, and any known competitors).
- **ai-search-researcher** with the brief in `prompts/ai-search-check.md` (fill in the business name, owner name, domain, and what it does).

Then run the scripts yourself:

```sh
./scripts/check-site.sh <domain> reviews/<run>
./scripts/check-dns.sh <domain> reviews/<run>
./scripts/crawler-access.sh <domain> reviews/<run>
./scripts/lighthouse-runs.sh https://<domain>/ 3 reviews/<run>    # takes about 3 minutes
```

## Step 2: browser pass (Chrome DevTools tools)

For the homepage and every main page listed in `evidence/pages.txt` (skip legal pages):

1. Set the viewport to 1440×900. Take a viewport screenshot and a full-page screenshot into `shots/`. Save `document.body.innerText`, every link and button label with its destination, and image alt text to `evidence/page-<name>.json` using the evaluate-script tool.
2. Set the viewport to 390×844 (mobile, touch) and screenshot the homepage's first screen. Measure where the main call-to-action button starts (its top in pixels) versus the 844px screen height. Check for horizontal scrolling.
3. Run the Lighthouse audit tool (accessibility, SEO, best practices, agentic browsing) on the homepage for mobile and desktop, saving reports to `evidence/lighthouse-mobile/` and `evidence/lighthouse-desktop/`.

Some sites fade content in on scroll, so full-page screenshots can show blank sections. If that happens, scroll and take viewport screenshots instead, and note it.

Then **read every page's text**. Most of the valuable findings come from reading, not tools: unclear headlines, offers without prices, mismatched labels, broken promises ("all prices are on the services page" when they aren't), typos, and missing proof.

## Step 3: verify before you conclude

- When the competitor researcher returns, re-check each quote it plans to use with `curl -sL -A "Mozilla/5.0" <url> | grep -i "<phrase>"` (also try after stripping tags, because text can be split across elements). Mark each as verified, changed, or not found.
- When the AI-search researcher returns, check that each finding rests on 3 runs. If not, run `node scripts/ask-ai.mjs` again for that question.
- Before claiming something is unique ("no competitor does X"), grep every competitor's raw homepage for the claim in several wordings (for independence, try: independent, agnostic, vendor-neutral, "do not sell"). In testing, this check found a competitor that did make a related claim, and the report's wording had to change.
- Cross-check the researchers against your own evidence. They make mistakes too. In testing, a researcher reported "no testimonials and no prices" for a site that had both, because it only read one page.

## Step 4: synthesize

Cover all eight areas in `docs/checklist.md`. Then decide:

- **What works**: 4 to 6 things to keep, especially anything competitors don't have.
- **Scorecard**: one line per area, rated Strong, Mixed, or Needs work.
- **Top 10 fixes**: ranked by impact on winning clients relative to effort. Mark items 1 to about 7 as quick wins (hours) and the rest as bigger moves. Each fix has a "why" with a number or quote from the evidence.
- **Homepage rewrite**: three headline, subhead, and button options. The first should say who it's for and what they get. Reuse the owner's best existing line when there is one.

## Step 5: write

1. Copy `template/report.html` to `reviews/<run>/report.html` and fill every section. Keep the section IDs. Link each finding to its evidence file with a relative path. Remove any section comment markers.
2. Write `reviews/<run>/summary-email.md`: a short note to the owner with the headline read and the top 5 fixes, in plain language, under 300 words.
3. Export a PDF the owner can open:
   ```sh
   "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --no-pdf-header-footer \
     --print-to-pdf="reviews/<run>/report.pdf" "file://$PWD/reviews/<run>/report.html"
   ```
   On Linux use `google-chrome` or `chromium` with the same flags.

## Step 6: final check (do all of these before saying you're done)

- Every number in the report appears in a file under `evidence/`.
- Every competitor quote is marked verified against raw HTML.
- Performance numbers are medians of 3 or more runs; AI-answer claims rest on 3 or more runs, or say "single sample."
- Nothing in the report says a form was submitted, a scan was run, or a meeting was booked.
- The "Method and limits" section lists what wasn't checked (see `docs/limits.md`).
- Open the report in the browser at 1440px and 390px wide and confirm there's no horizontal overflow or broken image.

Then tell the user where the report, PDF, and summary email are, the top 3 findings in one sentence each, and anything you couldn't verify.
