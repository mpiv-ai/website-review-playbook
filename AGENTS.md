# Agent instructions

Read and follow `CLAUDE.md` in this folder. It holds the full method and works for any coding agent (Claude Code, Codex, and others).

If your agent can't start subagents, do the work in `prompts/competitor-scan.md` and `prompts/ai-search-check.md` yourself, one after the other, before Step 2. If it has no browser tools, use `scripts/screenshots.sh` for screenshots and skip the Lighthouse accessibility audit (the performance runs in `scripts/lighthouse-runs.sh` still work).
