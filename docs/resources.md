# AI Tooling and Agentic Resources

## Skill Resources

* Claude Code Skill Docs: https://code.claude.com/docs/en/skills

* Anthropic's Skills Library: https://github.com/anthropics/skills


## Docs and information


https://docs.github.com/en/copilot/how-tos/use-copilot-agents/request-a-code-review/use-code-review#customizing-copilots-reviews-with-custom-instructions

Claude Code Skill Docs: https://code.claude.com/docs/en/skills

Anthropic's Skills Library: https://github.com/anthropics/skills

Other helpful skills: https://github.com/feiskyer/claude-code-settings


## MCP Servers

| Server | Purpose | Install |
|---|---|---|
| **qmd** | Semantic search over KB, notes, and repo docs (on-device, BM25 + vectors) | `npm install -g @tobilu/qmd` |
| **gspace** | Google Drive, Docs: upload reports, sync to shared docs | `gspace mcp stdio` |
| **phabricator** | Browse Phabricator repos, diffs, revisions | `npx @freelancercom/phabricator-mcp@latest` |
| **mcp-atlassian** | Jira: look up tickets, add comments, search issues (see [Setting Up Atlassian MCP](../docs/setting_up_atlassian_mcp.md) for setup) | `uvx mcp-atlassian` |
| **slack** | Search channels, read threads, send messages | Slack plugin (Claude Code marketplace) |
| **Sentry** | Reference and evaluate Sentry issues | `npx add-mcp https://mcp.sentry.dev/mcp` |

**links**

- [Jira/Atlassian](https://github.com/atlassian/atlassian-mcp-server)
- [Sentry](https://github.com/mcp/getsentry/sentry-mcp)
- [Sentry additional info](https://docs.sentry.io/ai/mcp/)


## Cool and helpful add-ons

- ["caveman" plugin for Claude](https://github.com/juliusbrussee/caveman)
- [learning-opportunities](https://github.com/DrCatHicks/learning-opportunities): A (Claude|Codex|OpenCode) skill for deliberate skill development during AI-assisted coding.
