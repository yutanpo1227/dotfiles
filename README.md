# Chezmoiを用いたdotfiles管理
## Chezmoiのインストール
```bash
brew install chezmoi
```

## Chezmoiの初期化
```bash
chezmoi init https://github.com/yutanpo1227/dotfiles.git
```

## Chezmoiの適用
```bash
chezmoi apply
```

## Codex trustの端末別運用

`~/.codex/config.toml` は `dot_codex/private_config.toml.tmpl` から生成されます。
`projects.*.trust_level` は `.chezmoidata` のデータで差し込みます。
`dot_config/chezmoi/chezmoi.toml.tmpl` の `hooks.read-source-state.pre` で、`chezmoi apply` 前に trust 同期を自動実行します。

### 端末ごとのtrustを吸収する手順

1. Codex CLIを使って通常どおり approval/trust を付与する
2. `chezmoi apply` を実行する（自動で trust 同期が走る）

```bash
chezmoi apply
```

手動で同期したい場合:

```bash
./scripts/sync_codex_trust_to_chezmoidata.sh
```

生成先: `.chezmoidata/codex.local.toml`（gitignore済み、端末ローカル専用）
