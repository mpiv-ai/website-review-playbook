# Brief: competitor scan

Fill in the bracketed parts, then hand this to the `competitor-researcher` subagent. This brief is a generalized copy of the one used in the original review.

---

Objective: produce a competitive scan for a website review of [BUSINESS NAME] ([URL]), [ONE-SENTENCE DESCRIPTION: who they serve, what they sell, how they position themselves, e.g. "an independent cybersecurity advisory for small healthcare practices and nonprofits that sells no products"]. Offers listed on the site: [OFFER NAMES].

Task: find 4-5 comparable firms. Prefer small, independent, or boutique firms and solo practitioners that sell [CORE SERVICES] to [TARGET CLIENTS] in [REGION]. Include at most one larger well-known firm as a reference point. [IF KNOWN: Include these named competitors: ...] Use web search and page fetches on public pages only. For each firm, record:

- name and URL
- who they target
- homepage headline (verbatim)
- offers and how they are packaged
- pricing or "starting at" signals (verbatim, with the page URL), or "none published"
- primary call to action, and any secondary call to action or free download
- trust signals (credentials, testimonials, case studies, client logos)
- one thing [BUSINESS NAME] could learn from them

For the positioning question below, grep each competitor's raw homepage for the claim in several wordings and quote any match.

Also note how [BUSINESS NAME]'s main positioning claim ([CLAIM, e.g. "independent, no products to sell"]) compares: is it rare or common among them?

Constraints: public pages only. Quote, don't paraphrase, for headlines and pricing, and confirm each quote against the raw HTML with curl. Every claim has a source URL. No invented numbers. If you couldn't verify something, say so. Don't contact anyone or fill in any forms.

Output: write a Markdown file to [RUN FOLDER]/evidence/competitors.md with one section per competitor, a comparison table (target, offers, pricing signal, primary CTA, free download), and a short "Implications" section (3-6 bullets). Budget: about 25 tool calls. Report back the file path and a 5-line summary.
