# Brief: AI search and entity check

Fill in the bracketed parts, then hand this to the `ai-search-researcher` subagent. This brief is a generalized copy of the one used in the original review, with one change: every AI question now runs 3 times per mode instead of once.

---

Objective: assess how AI assistants and search engines see [BUSINESS NAME] ([URL]), [ONE-SENTENCE DESCRIPTION] run by [OWNER NAME, CREDENTIALS] ([LINKEDIN URL if known]). Another worker handles security headers and competitors; don't duplicate those.

Do the following, public and passive only:

1. **How AI answer engines describe the business today.**
   (a) Write these questions to [RUN FOLDER]/evidence/ai/questions.txt, one per line:
   - What is [BUSINESS NAME]?
   - Who is [OWNER NAME], [CREDENTIAL], [BUSINESS NAME]?
   - [A buyer's question in their own words, e.g. "Recommend an independent cybersecurity advisor for a small healthcare practice that needs a HIPAA security risk assessment"]
   Then run `node scripts/ask-ai.mjs [RUN FOLDER]/evidence/ai/questions.txt [RUN FOLDER]/evidence/ai 3` if OPENAI_API_KEY is set. For each question and mode, tally the answers: correct, wrong company, invented, generic, or business absent. Note factual errors.
   (b) Web-search the business name, the name plus its field, the bare domain, and the owner's name plus credential. Record what ranks, whether the site appears, and any other businesses with confusingly similar names.
   Perplexity, Google AI Overviews, Gemini, and Copilot can't be tested from a terminal. Say so rather than guessing.
2. **Crawler access.** Read [RUN FOLDER]/evidence/crawler-access.txt (from `scripts/crawler-access.sh`). Note whether bots get the same pages as a browser, and whether robots.txt, llms.txt, and sitemap.xml exist and have content.
3. **Entity consistency.** Find public profiles: LinkedIn company page, the owner's LinkedIn headline and current role, Google Business Profile, directories (Clutch and others relevant to the field), BBB, and the state business registry. Record name, location, and description, and whether they match the site. Note what's missing and any spelling differences (business name, owner name, town).
4. **Could an AI agent find services, understand scope and price, and book a call without a person?** Fetch the services and booking pages with curl. Note whether the content is in the raw HTML or needs JavaScript, whether prices appear, and what booking widget is used.

Constraints: no form submissions, no booking, no contacting anyone, no scanning. Every claim backed by a saved file or a URL. Mark anything you couldn't check as "not verified."

Output: save raw files under [RUN FOLDER]/evidence/ai/ and write [RUN FOLDER]/evidence/ai-readiness.md with sections 1-4, each finding with its evidence. Budget: about 35 tool calls. Report back the path and a 6-line summary.
