# Python開発ツール ナレッジ

Python開発で使用するツールの学びを記録する。

## uv（パッケージマネージャー）

### 概要
- Rustで書かれた高速なPythonパッケージマネージャー
- pip/venv/pyenvの代替
- 公式: https://docs.astral.sh/uv/

### 基本コマンド
```bash
# プロジェクト初期化
uv init --no-workspace

# 依存追加
uv add strands-agents bedrock-agentcore

# スクリプト実行
uv run python script.py

# 仮想環境の場所
# .venv/ がプロジェクトルートに作成される
```
