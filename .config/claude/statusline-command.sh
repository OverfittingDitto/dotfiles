#!/bin/sh
# Claude Code statusLine
# Format: [repo] [branch]  ·  model  ·  ctx%  ·  5h gauge  │  7d gauge
# Theme: Catppuccin Frappe (256-color), no Nerd Fonts required

input=$(cat)

# Colors (Catppuccin Frappe)
CYAN=$(printf '\033[96m')            # Sky      — branch
GREEN=$(printf '\033[32m')           # Green    — gauge filled
LAVENDER=$(printf '\033[38;5;147m')  # Lavender — model name
BLUE=$(printf '\033[38;5;111m')      # Blue     — ctx / gauge empty
YELLOW=$(printf '\033[38;5;222m')    # Yellow   — ctx warning  >=70%
RED=$(printf '\033[38;5;210m')       # Red      — ctx critical >=90%
RESET=$(printf '\033[0m')

# Append $1 to $out with separator: "  " for git parts, "  ·  " for the rest
append()      { [ -n "$out" ] && out="${out}  ·  $1" || out="$1"; }
append_git()  { [ -n "$out" ] && out="${out}  $1"    || out="$1"; }

# ---- Parse JSON input ----
cwd=$(echo "$input"   | jq -r '.workspace.current_dir           // empty')
model=$(echo "$input" | jq -r '.model.display_name              // empty')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# ---- Git info ----
repo_name=""
branch=""
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  toplevel=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
  [ -n "$toplevel" ] && repo_name=$(basename "$toplevel")
fi

# ---- Gauge bar (10 blocks, filled=green / empty=blue) ----
make_bar() {
  filled=$(awk "BEGIN { n=int($1*10/100+0.5); print (n>10)?10:n }")
  empty=$((10 - filled))
  f="" e="" i=0
  while [ $i -lt "$filled" ]; do f="${f}▓"; i=$((i+1)); done
  i=0
  while [ $i -lt "$empty"  ]; do e="${e}░"; i=$((i+1)); done
  printf "${GREEN}%s${BLUE}%s${RESET}" "$f" "$e"
}

# ---- Assemble ----
out=""

# [repo] [branch]  — no · between them
[ -n "$repo_name" ] && out="[${repo_name}]"
[ -n "$branch" ]    && append_git "${CYAN}[${branch}]${RESET}"

# model name
[ -n "$model" ] && append "${LAVENDER}${model}${RESET}"

# ctx% — blue / yellow >=70% / red >=90%
if [ -n "$ctx_pct" ]; then
  ctx_int=$(printf '%.0f' "$ctx_pct")
  if   [ "$ctx_int" -ge 90 ]; then c="${RED}"
  elif [ "$ctx_int" -ge 70 ]; then c="${YELLOW}"
  else                              c="${BLUE}"
  fi
  append "${c}ctx ${ctx_int}%${RESET}"
fi

# rate limit gauges
if [ -n "$five_pct" ] || [ -n "$week_pct" ]; then
  gauges=""
  if [ -n "$five_pct" ]; then
    five_int=$(printf '%.0f' "$five_pct")
    gauges="5h $(make_bar "$five_pct") ${five_int}%"
  fi
  if [ -n "$week_pct" ]; then
    week_int=$(printf '%.0f' "$week_pct")
    week_str="7d $(make_bar "$week_pct") ${week_int}%"
    [ -n "$gauges" ] && gauges="${gauges}  │  ${week_str}" || gauges="${week_str}"
  fi
  append "$gauges"
fi

printf '%s' "${out}"
