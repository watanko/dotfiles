---
description: Codex CLIを使って実装をレビューする。コードレビューを依頼された時や /codex-review で手動実行。
allowed-tools: Bash(codex *), Bash(git *)
argument-hint: "[file-path or branch]"
---

# Codex Code Review

Codex CLIを使って実装のレビューを行います。

## Review target

$ARGUMENTS

## Changed files

!`git diff --stat HEAD~1 2>/dev/null || echo "No git history available"`

## Detailed diff

!`git diff HEAD~1 2>/dev/null | head -3000 || echo "No diff available"`

## Instructions

1. If $ARGUMENTS is provided, review those specific files
2. If no arguments, review the changes shown above (git diff)
3. Run Codex CLI to get a review:

```bash
# For specific files
codex -q "Review the following code for bugs, security issues, and improvements. Be concise and actionable. Focus on: correctness, edge cases, type safety, and naming. Reply in Japanese." < <file>

# For git diff
git diff HEAD~1 | codex -q "Review this diff for bugs, security issues, and improvements. Be concise and actionable. Focus on: correctness, edge cases, type safety, and naming. Reply in Japanese."
```

4. Present the Codex review output to the user
5. Add your own synthesis if Codex missed anything important
