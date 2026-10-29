# How the original review was run

This playbook comes from a real review of a small advisory firm's website in October 2026. This page records how that review was run, which agents did what, and what we changed in the playbook afterward. The client isn't named.

## The agents

| Agent | Model | Job | Tools |
|---|---|---|---|
| Orchestrator | Claude Opus (Claude Code CLI) | Planned the work, ran every hands-on check, verified the researchers' claims, wrote the report and summary email | curl, openssl, dig, Chrome DevTools (screenshots, page text, Lighthouse), Lighthouse CLI |
| Competitor researcher | Claude Sonnet (subagent) | Found and profiled 5 comparable firms | Web search, web fetch, curl |
| AI-search researcher | Claude Sonnet (subagent) | Asked OpenAI's model about the business, tested crawler access, checked entity consistency and whether an agent could book a call | OpenAI Responses API (gpt-4.1-mini, with and without web search), curl, web search |

The orchestrator started both researchers in the background at the beginning, then did its own checks while they worked. Each researcher got a written brief with an objective, constraints, an output file path, and a tool-call budget. The generalized versions of those briefs are in [`prompts/`](../prompts/). Each researcher took about 20 to 25 tool calls and 2 to 5 minutes.

## The sequence

1. **Kickoff.** The orchestrator fetched the homepage, read the titles and links, and found the platform (from response headers) and the page list.
2. **Parallel research.** It started the two researchers with their briefs.
3. **Server and DNS checks.** It recorded status and timing for every page, redirects, missing-page behavior, security headers, TLS, robots.txt, sitemap, and llms.txt, plus MX, SPF, DMARC, DKIM, CAA, and DNSSEC.
4. **Email headers.** It read the authentication lines of an email the business had sent. That's how it found mail arriving unsigned (no DKIM), which DNS alone couldn't show.
5. **Browser pass.** It took desktop and mobile screenshots of every main page, saved each page's text and links, measured where the main button sat on a phone screen, and ran Lighthouse accessibility, SEO, and best-practice audits.
6. **Performance.** Google's PageSpeed API had hit its daily quota, so it ran Lighthouse locally 3 times on mobile and 3 times on desktop and reported medians. One mobile run scored 54 and the other two scored 70. A single run would have misled.
7. **Reading.** It read every page's copy for offers, prices, buttons, proof, free downloads, typos, and broken promises. Most of the top 10 fixes came from this step, not from tools.
8. **Synthesis.** It rated eight areas, ranked 10 fixes by impact and effort, and wrote three headline rewrites.
9. **Writing and checks.** It wrote the HTML report from evidence files, exported a PDF, checked the layout at desktop and phone widths, and drafted a short email.

## What we changed afterward

These gaps showed up in the original run and are now built into the method:

- **Repeat AI questions.** The first run asked each question once. One answer found a different company with a similar name, which is a striking finding to rest on one sample. The method now runs every question 3 times per mode (`scripts/ask-ai.mjs`).
- **Verify competitor quotes against raw HTML.** The researcher read pages through a summarizing fetch tool and flagged that its quotes might be paraphrased. Quotes are now checked with curl and grep before they go in a report.
- **Cross-check researchers against your own evidence.** The competitor researcher reported that the client's site had "no testimonials" and "no prices," because it only opened one page. Both existed on other pages. The orchestrator caught it. The method now requires this cross-check.
- **Check uniqueness claims.** The report first said no competitor made the client's independence argument. A grep of each competitor's raw homepage found one that says it is "Product Agnostic" and sells no third-party products. The claim was narrowed to what was true: nobody made the client's full pledge. The method now requires this check.
- **Screenshots of animated pages.** Full-page captures rendered some scroll-animated sections blank. The method now says to use viewport screenshots for anything in the report.

## Cost and time

About 25 minutes of agent time, mostly waiting on Lighthouse and the researchers. AI-answer checks cost cents. The rest uses free tools.
