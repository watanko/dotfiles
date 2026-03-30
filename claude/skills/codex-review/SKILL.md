---
description: Codex CLIを使って実装をレビューする。コードレビューを依頼された時や /codex-review で手動実行。
allowed-tools: Bash(codex *), Bash(git *)
argument-hint: "[--uncommitted | --commit <sha> | --base <branch>]"
---

# Codex Code Review

Codex CLIを使って実装のレビューを行います。

## Review target

$ARGUMENTS

## Changed files

!`git diff --stat HEAD~1 2>/dev/null || git diff --stat 2>/dev/null || echo "No changes found"`

## Detailed diff

!`git diff HEAD~1 2>/dev/null | head -3000 || git diff 2>/dev/null | head -3000 || echo "No diff available"`

## Instructions

1. Run Codex CLI to get a review using the appropriate mode:

```bash
# Uncommitted changes (staged + unstaged + untracked)
codex review --uncommitted

# Specific commit
codex review --commit <sha>

# Changes against a base branch
codex review --base main
```

2. If $ARGUMENTS is provided, pass it directly to `codex review` (e.g. `codex review --uncommitted`, `codex review --commit abc123`)
3. If no arguments, choose the appropriate mode:
   - If there are uncommitted changes: `codex review --uncommitted`
   - If reviewing the latest commit: `codex review --commit HEAD`
4. Present the Codex review output to the user
5. Add your own synthesis if Codex missed anything important
