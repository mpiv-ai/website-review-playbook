# Website review playbook

An agent-run method for reviewing a small business website and producing a report the owner can act on. It covers speed, mobile, SEO, site security signals, email authentication, positioning, offers, AI-search visibility, and competitors. The report ranks the top 10 fixes and includes the evidence for each one.

You run it from the command line with [Claude Code](https://docs.claude.com/en/docs/claude-code/overview). The agent follows the method in [`CLAUDE.md`](CLAUDE.md), starts two research subagents in parallel, runs the check scripts, drives a browser for screenshots and audits, and writes the report.

Everything is passive: public pages, DNS, and HTTP responses. Nothing scans the site, submits a form, or contacts anyone.

## What you get

For each review, a folder under `reviews/<domain>-<date>/` with:

- `report.html` and `report.pdf`: what works, a scorecard for 8 areas, the top 10 fixes ranked by impact and effort, three homepage headline rewrites, and the detail behind each finding.
- `summary-email.md`: a short note to the owner with the headline read and top 5 fixes. It's a draft; you send it.
- `evidence/` and `shots/`: the raw output and screenshots every finding points to.

## Setup (about 10 minutes, once)

**On Windows?** Follow [Windows setup](docs/windows-setup.md) instead of this section, then come back to [Run a review](#run-a-review).

On macOS or Linux you need:

| Tool | Check | Install |
|---|---|---|
| Node.js 22.12 or newer | `node -v` | [nodejs.org](https://nodejs.org) or `brew install node` |
| Google Chrome | open it | [google.com/chrome](https://www.google.com/chrome/) |
| curl, openssl, dig | `dig -v` | Included on macOS. Linux: `sudo apt install curl openssl dnsutils` |
| Claude Code | `claude --version` | `npm install -g @anthropic-ai/claude-code`, then run `claude` once to sign in (needs a Claude Pro or Max plan, or an Anthropic API key) |

Optional, for the AI-answer checks: an OpenAI API key from [platform.openai.com](https://platform.openai.com/api-keys). Each review uses about 18 small calls on `gpt-4.1-mini`, typically well under $1.

```sh
git clone https://github.com/mpiv-ai/website-review-playbook.git
cd website-review-playbook
export OPENAI_API_KEY=sk-...    # optional
claude
```

The first time Claude Code opens this folder, it asks whether to trust the folder and whether to enable the project's browser tool (`chrome-devtools`). Say yes to both.

## Run a review

Inside Claude Code, type:

```
/review example.com
```

The agent asks a few intake questions in one message: who the business serves, any known competitors, and whether you have the headers of an email sent from the domain (see [`docs/email-headers.md`](docs/email-headers.md)). Answer, or say "go" to use defaults. A full review takes about 30 to 45 minutes. Claude Code asks permission before commands that aren't pre-approved in `.claude/settings.json`. Read each one and approve it.

When it's done, open `reviews/<domain>-<date>/report.html` in your browser. Read the report before you send anything. The agent's job is evidence and a first draft. The judgment about what matters for this client is yours.

## Run the checks by hand

Each script works on its own and writes into `reviews/<domain>-<date>/evidence/`. On Windows, run them in Git Bash (see [Windows setup](docs/windows-setup.md#run-the-checks-by-hand)):

```sh
./scripts/check-site.sh example.com          # pages, timing, redirects, headers, robots/sitemap/llms.txt, TLS, SEO facts
./scripts/check-dns.sh example.com           # MX, SPF, DMARC, DKIM selectors, CAA, DNSSEC
./scripts/crawler-access.sh example.com      # do AI and search bots get the same pages?
./scripts/lighthouse-runs.sh https://example.com/ 3   # 3 mobile + 3 desktop performance runs, median
node scripts/ask-ai.mjs examples/questions.txt reviews/example.com-ai 3   # AI answers, 3 runs each
./scripts/screenshots.sh https://example.com/        # fallback screenshots without the browser tool
```

## How it works

- [`CLAUDE.md`](CLAUDE.md): the method the agent follows, step by step, including the rules it can't break.
- [`.claude/agents/`](.claude/agents/): the two research subagents (competitors, and AI search and entity checks).
- [`prompts/`](prompts/): the briefs the agent fills in and hands to each subagent.
- [`docs/checklist.md`](docs/checklist.md): the eight review areas and what counts as evidence.
- [`docs/methodology.md`](docs/methodology.md): how the original review was run, which agents and models did what, and what we changed afterward.
- [`docs/limits.md`](docs/limits.md): what this doesn't cover.
- [`docs/windows-setup.md`](docs/windows-setup.md): installing and running on Windows.
- [`template/report.html`](template/report.html): the report layout.

## Rules

1. Review sites you have permission to review: your own, a client's, or a prospect who asked.
2. Passive checks only. Don't add scanning tools to this method without a signed authorization.
3. Every finding needs evidence. If the agent can't show it, it doesn't go in the report.
4. `reviews/` is git-ignored because it can hold client details. Keep it that way.

## Security notes

The agent reads web pages you don't control, and a page can contain text written to manipulate an AI agent. The playbook limits what that text could do:

- The scripts that run without asking accept only a plain domain or an http(s) URL, and they write only inside `reviews/`. The AI-answer script reads questions only from `reviews/` or `examples/`.
- Form-filling and file-upload browser tools are blocked in `.claude/settings.json`. Other commands, including `curl`, ask for your approval each time.
- The browser tool runs in an isolated profile (`--isolated`) and its version is pinned in `.mcp.json`.
- Web search and page fetches are pre-approved because reading public pages is the job. If you'd rather approve each fetch, remove `WebFetch` from `.claude/settings.json`.

Don't keep secrets in this folder. Keep `OPENAI_API_KEY` in your shell environment, not in a file here.

## License

MIT. See [LICENSE](LICENSE).
