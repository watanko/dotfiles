#!/bin/bash
# Pre-commit hook: run Codex review on staged changes before allowing commit.
# Called by Claude Code's PreToolUse hook for Bash(git commit *).
# Reads tool input from stdin (JSON), reviews staged diff with Codex,
# and denies the commit if issues are found.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Only intercept git commit commands
if ! echo "$COMMAND" | grep -qE '^git\s+commit'; then
  exit 0
fi

DIFF=$(git diff --cached 2>/dev/null)

# Nothing staged — let git handle the error
if [ -z "$DIFF" ]; then
  exit 0
fi

REVIEW=$(echo "$DIFF" | codex -q \
  "You are a strict code reviewer. Review this diff for:
1. Bugs and logical errors
2. Security vulnerabilities
3. Type safety issues
4. Missing edge case handling

If you find issues, start your response with 'ISSUES FOUND:' followed by a numbered list.
If the code looks good, start your response with 'LGTM'.
Be concise. Reply in Japanese." 2>/dev/null || echo "LGTM (Codex unavailable)")

if echo "$REVIEW" | grep -qi "ISSUES FOUND"; then
  jq -n --arg reason "$REVIEW" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": $reason
    }
  }'
else
  # Review passed — output as decision reason so Claude sees the review
  jq -n --arg reason "$REVIEW" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "allow",
      "permissionDecisionReason": $reason
    }
  }'
fi
