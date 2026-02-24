#!/bin/bash
# Codex Plan Review Script
# Usage: bash review-plan.sh "<plan content or file path>"
# Exit codes: 0=success, 1=codex not found, 2=review failed

set -euo pipefail

PLAN_INPUT="${1:-}"
RESULT_FILE="/tmp/codex-plan-review-$(date +%s).txt"

# --- Codex CLI存在チェック ---
if ! command -v codex &>/dev/null; then
  echo "⚠️  Codex CLIが見つかりません。レビューをスキップします。"
  echo "   インストール: npm install -g @openai/codex"
  exit 1
fi

# --- 入力チェック ---
if [ -z "$PLAN_INPUT" ]; then
  echo "⚠️  プラン内容が指定されていません。"
  echo "   Usage: bash review-plan.sh \"<plan content or file path>\""
  exit 1
fi

# --- プラン内容の取得 ---
if [ -f "$PLAN_INPUT" ]; then
  PLAN_CONTENT=$(cat "$PLAN_INPUT")
else
  PLAN_CONTENT="$PLAN_INPUT"
fi

# --- レビュー実行 ---
echo "🔍 Codexによるプランレビューを実行中..."

PROMPT=$(cat <<PROMPT_EOF
あなたは経験豊富なシニアソフトウェアアーキテクトです。
以下の実装プランをレビューし、問題点や改善案を報告してください。

## レビュー観点
- **Architecture**: アーキテクチャの妥当性、過剰設計/設計不足
- **Edge Cases**: 見落としているエッジケースやエラーハンドリング
- **Performance**: パフォーマンス上の懸念
- **Security**: セキュリティリスク
- **Alternatives**: より良いアプローチの提案

## 出力形式
各指摘について以下を記載:
1. 重要度（Critical/High/Medium/Low）
2. 問題の説明
3. 改善案

最後に総合評価を記載してください。
日本語で回答してください。

## プラン内容

${PLAN_CONTENT}
PROMPT_EOF
)

if timeout 120 codex exec \
  --sandbox read-only \
  --ephemeral \
  -o "$RESULT_FILE" \
  "$PROMPT" 2>/dev/null; then

  if [ -f "$RESULT_FILE" ] && [ -s "$RESULT_FILE" ]; then
    echo ""
    echo "=== Codex Plan Review Result ==="
    echo ""
    cat "$RESULT_FILE"
    echo ""
    echo "================================"
    rm -f "$RESULT_FILE"
    exit 0
  fi
fi

echo "⚠️  Codexレビューが失敗またはタイムアウトしました。スキップします。"
rm -f "$RESULT_FILE"
exit 2
