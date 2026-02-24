#!/bin/bash
# Codex Code Review Script
# Usage: bash review-code.sh [base-branch]
# Exit codes: 0=success, 1=codex not found, 2=review failed

set -euo pipefail

BASE_BRANCH="${1:-main}"
RESULT_FILE="/tmp/codex-code-review-$(date +%s).txt"

# --- Codex CLI存在チェック ---
if ! command -v codex &>/dev/null; then
  echo "⚠️  Codex CLIが見つかりません。レビューをスキップします。"
  echo "   インストール: npm install -g @openai/codex"
  exit 1
fi

# --- Git差分チェック ---
DIFF=$(git --no-pager diff --unified=5 "${BASE_BRANCH}"...HEAD 2>/dev/null || git --no-pager diff --unified=5 HEAD 2>/dev/null || echo "")
STAGED_DIFF=$(git --no-pager diff --cached --unified=5 2>/dev/null || echo "")
UNSTAGED_DIFF=$(git --no-pager diff --unified=5 2>/dev/null || echo "")

# 差分を結合（ブランチdiff優先、なければstaged+unstaged）
if [ -n "$DIFF" ]; then
  ALL_DIFF="$DIFF"
elif [ -n "$STAGED_DIFF" ] || [ -n "$UNSTAGED_DIFF" ]; then
  ALL_DIFF="${STAGED_DIFF}${UNSTAGED_DIFF}"
else
  echo "ℹ️  レビュー対象の差分がありません。スキップします。"
  exit 0
fi

# 差分が大きすぎる場合は警告
DIFF_LINES=$(echo "$ALL_DIFF" | wc -l)
if [ "$DIFF_LINES" -gt 3000 ]; then
  echo "⚠️  差分が大きいため（${DIFF_LINES}行）、変更ファイル一覧のみでレビューします。"
  ALL_DIFF=$(git --no-pager diff --stat "${BASE_BRANCH}"...HEAD 2>/dev/null || git --no-pager diff --stat HEAD 2>/dev/null)
fi

# --- レビュー実行 ---
echo "🔍 Codexによるコードレビューを実行中..."

PROMPT_FILE=$(mktemp)
cat > "$PROMPT_FILE" <<PROMPT_EOF
あなたは経験豊富なシニアエンジニアのコードレビューアーです。
以下のgit diffをレビューし、問題点を報告してください。

## レビュー観点
- **Correctness**: ロジックの正確性、エッジケース、エラーハンドリング
- **Performance**: N+1クエリ、不要な再レンダリング、メモリリーク
- **Security**: インジェクション、XSS、認証バイパス、機密情報の露出
- **Maintainability**: コードの可読性、命名、テストの欠如
- **Best Practices**: フレームワーク固有のベストプラクティス準拠

## 出力形式
各問題について以下を記載:
1. ファイルパスと行番号（わかる場合）
2. 重要度（Critical/High/Medium/Low）
3. 問題の説明と修正案

良い点も記載してください。
最後に総合評価を記載してください。
日本語で回答してください。

## diff

${ALL_DIFF}
PROMPT_EOF

if timeout 180 cat "$PROMPT_FILE" | codex exec \
  --sandbox read-only \
  --ephemeral \
  -o "$RESULT_FILE" \
  - 2>/dev/null; then

  if [ -f "$RESULT_FILE" ] && [ -s "$RESULT_FILE" ]; then
    echo ""
    echo "=== Codex Code Review Result ==="
    echo ""
    cat "$RESULT_FILE"
    echo ""
    echo "================================="
    rm -f "$RESULT_FILE" "$PROMPT_FILE"
    exit 0
  fi
fi

echo "⚠️  Codexレビューが失敗またはタイムアウトしました。スキップします。"
rm -f "$RESULT_FILE" "$PROMPT_FILE"
exit 2
