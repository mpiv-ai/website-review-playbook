# Windows setup

This is the Windows version of the [Setup](../README.md#setup-about-10-minutes-once) section in the README. Everything after setup, from `/review` onward, is the same on every platform.

Claude Code runs natively on Windows 10 (version 1809 or later) and Windows 11. The playbook's check scripts are bash scripts, so this setup installs Git for Windows, which provides Git Bash along with the `curl` and `openssl` the scripts use. Claude Code finds Git Bash on its own and runs the scripts there.

Run every command below in **PowerShell** (your prompt starts with `PS C:\`). You don't need to run it as Administrator.

## 1. Install the tools

| Tool | Install | Check (in a new PowerShell window) |
|---|---|---|
| Git for Windows | `winget install --id Git.Git -e` | `git --version` |
| Node.js 22.12 or newer | `winget install --id OpenJS.NodeJS.LTS -e` | `node -v` |
| Google Chrome | `winget install --id Google.Chrome -e` | Open it once |
| Claude Code | `irm https://claude.ai/install.ps1 \| iex` | `claude --version` |

If you'd rather not use `winget`, download the installers from [git-scm.com/downloads/win](https://git-scm.com/downloads/win), [nodejs.org](https://nodejs.org), and [google.com/chrome](https://www.google.com/chrome/). If you install Git by hand, keep the "Add to PATH" option selected.

Close PowerShell and open a new window after installing, so it picks up the new `PATH`. Then confirm Git Bash has what the scripts need:

```powershell
& "C:\Program Files\Git\bin\bash.exe" -c "curl --version | head -1; openssl version; node -v"
```

You need a Claude Pro, Max, Team, or Enterprise plan, or an Anthropic Console account, to sign in to Claude Code. The free plan doesn't include it.

Optional, for the AI-answer checks: an OpenAI API key from [platform.openai.com](https://platform.openai.com/api-keys). Each review uses about 18 small calls on `gpt-4.1-mini`, typically well under $1.

## 2. Get the playbook and start Claude Code

```powershell
git clone https://github.com/mpiv-ai/website-review-playbook.git
cd website-review-playbook
$env:OPENAI_API_KEY = "sk-..."    # optional; lasts until you close this window
claude
```

The first time, `claude` opens your browser to sign in. Then it asks whether to trust the folder and whether to enable the project's browser tool (`chrome-devtools`). Say yes to both.

To keep the OpenAI key across windows, run `setx OPENAI_API_KEY "sk-..."` once and open a new PowerShell window. That stores it in your Windows user environment, not in this folder.

Inside Claude Code, type `/mcp` and check that `chrome-devtools` shows as connected. The first connection downloads the browser tool through `npx`, so give it a minute.

## 3. Run a review

Inside Claude Code:

```
/review example.com
```

Then follow [Run a review](../README.md#run-a-review) in the README. When the review is done, open the report from PowerShell:

```powershell
Invoke-Item reviews\example.com-2026-10-29\report.html
```

Use the folder name the agent reports; the date is the day you ran it.

## What's different on Windows

- **The agent runs the scripts in Git Bash.** Claude Code on Windows has a Bash tool (Git Bash) and a PowerShell tool. The playbook tells the agent to run its scripts with the Bash tool, which is also what the pre-approved commands in `.claude/settings.json` cover. If the agent asks to run a script through PowerShell, tell it to use the Bash tool.
- **No `dig`.** Windows doesn't include `dig`, so `check-dns.sh` looks up records with Node's DNS resolver instead. It checks the same records except DNSSEC, and `dns.txt` says so. If you install `dig` yourself and it's on Git Bash's `PATH`, the script uses it.
- **No `whois`.** The domain creation date is skipped. Look it up on a registrar's website if you need it.

## Run the checks by hand

Open **Git Bash** from the Start menu, `cd` to the playbook folder, and run the same commands as in [Run the checks by hand](../README.md#run-the-checks-by-hand) in the README.

From PowerShell, call Git Bash by its full path:

```powershell
& "C:\Program Files\Git\bin\bash.exe" ./scripts/check-site.sh example.com
```

Don't type plain `bash` in PowerShell. If WSL is installed, `bash` starts Linux instead of Git Bash.

## Troubleshooting

**`claude` is not recognized.** Open a new PowerShell window first. If it still fails, check that the installer put the program in place with `Test-Path "$env:USERPROFILE\.local\bin\claude.exe"`. If that prints `True`, add `%USERPROFILE%\.local\bin` to your user `PATH`. See [Fix your PATH](https://code.claude.com/docs/en/troubleshoot-install#command-not-found-claude-after-installation).

**Claude Code can't find Git Bash.** Run `where.exe git` to find your Git install. Then add the path to its `bin\bash.exe` to your Claude Code user settings at `%USERPROFILE%\.claude\settings.json` (not the playbook's `.claude\settings.json`):

```json
{
  "env": {
    "CLAUDE_CODE_GIT_BASH_PATH": "C:\\Program Files\\Git\\bin\\bash.exe"
  }
}
```

**`running scripts is disabled on this system`** when you run `npm` or `npx` in PowerShell. Allow local scripts for your user, then retry:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**A script fails with `$'\r': command not found`.** The script has Windows line endings, which bash can't read. A fresh `git clone` of this repo checks the scripts out with Unix line endings. If your copy came from somewhere else, or was cloned before the Windows setup was added, move any `reviews\` folders out, delete the playbook folder, and clone it again.

**`chrome-devtools` doesn't connect in `/mcp`.** Check that `node -v` prints 22.12 or newer and that Chrome is installed, then restart `claude`. Until it connects, the agent can still take screenshots with `scripts/screenshots.sh` and run the performance checks.

**`screenshots.sh` says Chrome not found.** It looks in Chrome's standard install folders. If Chrome is somewhere else, set the path in Git Bash before running it: `export CHROME="/c/path/to/chrome.exe"`.

## Prefer WSL?

You can also run Claude Code inside WSL 2 (Windows Subsystem for Linux). In that case, follow the main README's Linux steps inside your Linux distribution, including installing Chrome there. This guide covers native Windows only.

Official references: [Claude Code setup on Windows](https://code.claude.com/docs/en/setup#set-up-on-windows) and [installation troubleshooting](https://code.claude.com/docs/en/troubleshoot-install).
