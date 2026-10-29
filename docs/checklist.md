# The eight review areas

Cover every area. Each finding needs a piece of evidence: a file, a screenshot, a measured number, or a quote.

## 1. Technical

- Speed and Core Web Vitals on mobile and desktop (3+ runs, median), page weight, image handling. Evidence: `evidence/perf/summary.txt`.
- Mobile layout: where the main button sits relative to the first screen, horizontal scrolling, tap target sizes.
- Accessibility basics: contrast, alt text, heading order, keyboard focus. Evidence: Lighthouse accessibility reports.
- Technical SEO: titles, meta descriptions, headings, canonical tags, sitemap.xml, robots.txt, structured data (Organization, ProfessionalService, Person, FAQPage, Offer), missing-page behavior, duplicate URLs. Evidence: `page-meta.txt`, `http.txt`.
- Site security posture, passive only: TLS version, certificate, HTTPS redirects, security headers, exposed CMS or plugin versions, spam protection on forms (look for Turnstile or reCAPTCHA in the HTML; don't submit). Evidence: `headers.txt`, `tls.txt`.
- Email and domain authentication: MX, SPF, DKIM, DMARC, plus CAA, DNSSEC, MTA-STS. Evidence: `dns.txt` and, for DKIM, real email headers (`docs/email-headers.md`).
- Hosting and platform, analytics and tracking tags, privacy policy, cookie handling.

For a security, legal, finance, or healthcare business, the security and email items are credibility signals, so rank them higher.

## 2. Design and UX

- Five-second test: from the first screen alone, can a visitor tell who it's for, what they get, and why this firm?
- Visual hierarchy, typography, imagery (stock or real), whitespace, consistency across pages.
- Navigation: does every menu item lead somewhere useful? Page count and depth.
- Trust signals: credentials, track record, client logos, testimonials (and where they sit on the page), case studies, a real photo of the owner.

## 3. Target market and positioning

- Who the ideal client is, and whether the site says so plainly and early.
- The words buyers actually use for the problem, and whether the site uses them. Make a table: buyer phrase, and where it appears.
- What sets the firm apart from competitors, and whether that's said on the first screen.
- Proof: specific results, before-and-after stories, sectors served.

## 4. Offers and calls to action

- Each offer: scope, deliverable, timeline, price or "starting at."
- Primary call to action on every page; a secondary option for visitors not ready to talk.
- Friction: form length, required fields, consent boxes, scheduler, any promise of a reply time.
- Consistency: same button labels and destinations everywhere.
- Free downloads (lead magnets): do they exist, where are they linked, are they error-free, and is there a follow-up path?

## 5. AI search readiness (AEO)

- How AI assistants describe the business today (3+ runs per question).
- AI crawler access, llms.txt, schema markup, answer-ready content (clear FAQs; service pages that state who, what, price, and outcome).
- Could an AI agent find the services, understand them, and book a call without a person?
- Entity consistency across LinkedIn, Google Business Profile, directories, and the site.

## 6. Content and search visibility (SEO)

- Searches buyers are likely to type that have no matching page. (Without keyword tools this is judgment; say so.)
- Article ideas the owner can write from their own experience.
- Alignment between the owner's LinkedIn and the site.

## 7. Competitive scan

- 3 to 5 comparable firms: positioning, offers, pricing signals, calls to action, free downloads, proof. From `evidence/competitors.md`, with verified quotes.

## 8. Recommendations

- Top 10 fixes ranked by impact and effort, quick wins first.
- Three homepage headline, subhead, and button rewrites.
