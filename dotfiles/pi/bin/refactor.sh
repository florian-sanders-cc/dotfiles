#!/usr/bin/env bash
set -euo pipefail

instruction="${*:-refactor to be cleaner and more idiomatic}"
model="${PI_REFACTOR_MODEL:-opencode/big-pickle}"
code=$(cat)

# Detect leading whitespace of first non-blank line
indent=$(printf '%s' "$code" | awk '
  /[^[:space:]]/ {
    match($0, /^[[:space:]]*/)
    print substr($0, 1, RLENGTH)
    exit
  }
')

# Dedent: strip that exact prefix from lines that start with it
stripped=$(printf '%s' "$code" | awk -v ind="$indent" '
  {
    if (ind != "" && substr($0, 1, length(ind)) == ind)
      print substr($0, length(ind) + 1)
    else
      print $0
  }
')

pi -p --no-session --thinking off \
  --model "$model" \
  --system-prompt "You are a code transformation tool. Output ONLY the transformed code. Absolute rules:
- No explanation, no commentary, no preamble, no postamble.
- No markdown code fences (no \`\`\`).
- Preserve the language and internal indentation style (tabs vs spaces) of the input.
- If the instruction cannot be fulfilled safely, output the input unchanged." \
  "Transform the following code per this instruction: $instruction

Code:
$stripped" \
  | awk -v ind="$indent" '
      /^```/ { next }                                # strip code fences
      !started && /^[[:space:]]*$/ { next }          # strip leading blank lines
      { started = 1; buf[++n] = $0 }
      END {
        while (n > 0 && buf[n] ~ /^[[:space:]]*$/) n--   # strip trailing blank lines
        for (i = 1; i <= n; i++) {
          if (buf[i] ~ /^[[:space:]]*$/) print buf[i]    # keep blank lines as-is
          else print ind buf[i]                          # re-apply indent to content lines
        }
      }
    '
