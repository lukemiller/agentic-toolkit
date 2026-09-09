---
description: Read PR review comments provided by GitHub Copilot and implement changes if needed
allowed-tools: Bash(gh *)
argument-hint: <automatically apply fixes: auto | manual>
---

# Github PR Review cycle automation

Perform an defensive review on PR Feedback comments, summarize necessary changes, propose solutions and implement if requested or specified via argument.

## Step 1:

On the current branch, run `gh pr view --comments` and `gh pr diff` to get the full context of the Copilot PR review comments.

## Step 2:

Review comments left by Copilot and evaluate the accuracy of the feedback. Do not implicitly trust copilot's recommended changes! If review comments are deemed relevant, propose the necessary code changes and summarize why.

Struture proposed changes along with the PR comment the address in a numbered list for approval in the following step.

**STOP.** Do not make any changes until the user gives an unambiguous go-ahead or $0 is set to `auto`.  Prompt with "Would you like me to apply any of these fixes?"
User can approved specific fixes by number or just "all".

## Step 3:

Apply the fixes specified by the user and return a summary of the changes

**STOP:** do not commit or push any of the changes unless directly and explicitly specified by the user.
