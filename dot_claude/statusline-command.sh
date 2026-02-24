#!/bin/bash
# Claude Code Status Line
# 📁 ディレクトリ │ 🤖 モデル │ 💰 コスト │ 📊 コンテキスト

input=$(cat)

# --- データ取得 ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
model_id=$(echo "$input" | jq -r '.model.id // empty')
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- 作業ディレクトリ（短縮表示）---
dir_part=""
if [ -n "$cwd" ]; then
  short="${cwd/#$HOME/~}"
  dir_part=$(printf '\033[1;34m📁 %s\033[0m' "$short")
fi

# --- モデル名（短くわかりやすく）---
model_part=""
if [ -n "$model_id" ]; then
  case "$model_id" in
    *opus*)   label="Opus 4.6"   ;;
    *sonnet*) label="Sonnet 4.6" ;;
    *haiku*)  label="Haiku 4.5"  ;;
    *)        label="$model_id"  ;;
  esac
  model_part=$(printf '\033[1;36m🤖 %s\033[0m' "$label")
fi

# --- コスト ---
cost_part=""
if [ -n "$cost_usd" ] && [ "$cost_usd" != "null" ]; then
  cost_part=$(printf '\033[1;33m💰 $%s\033[0m' "$(printf '%.4f' "$cost_usd")")
fi

# --- コンテキスト使用量（バー表示）---
ctx_part=""
if [ -n "$used_pct" ]; then
  pct=$(printf "%.0f" "$used_pct" 2>/dev/null)
  if [ -n "$pct" ]; then
    # 色分け
    if [ "$pct" -ge 80 ]; then
      color='\033[1;31m'  # 赤太字
    elif [ "$pct" -ge 50 ]; then
      color='\033[1;33m'  # 黄太字
    else
      color='\033[1;32m'  # 緑太字
    fi

    # プログレスバー生成 (10セグメント)
    filled=$((pct / 10))
    empty=$((10 - filled))
    bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    ctx_part=$(printf "${color}📊 %s %s%%\033[0m" "$bar" "$pct")
  fi
fi

# --- 結合して出力 ---
sep=$(printf ' \033[2m│\033[0m ')
output=""
for part in "$dir_part" "$model_part" "$cost_part" "$ctx_part"; do
  if [ -n "$part" ]; then
    if [ -n "$output" ]; then
      output+="$sep"
    fi
    output+="$part"
  fi
done

printf "%s" "$output"
