# Node.jsにおけるパッケージマネージャー
基本的にNode.jsにおいてパッケージマネージャーは複数の種類(npm, pnpmなど)が予想されるためコマンドは`ni`を使って自動的に差異を吸収する。
よって`npm (run|install)`や`pnpm (run|install)`などは使わないこと

## `ni`について
- github: `https://github.com/antfu-collective/ni`

### install系
```bash
# install
ni
# viteをinstall
ni vite
# @types/nodeをdevDependanciesにinstall
ni @types/node -D
# clean install
ni --frozen
# 同じくclean install
nci
# eslintをglobal install
ni -g eslint

# upgrade
nu
# upgrade-interactive
nu -i

# uninstall
nun webpack
```

### run系
```bash
# いつものrunコマンド
nr dev --port=3000

# scriptをインタラクティブに決定できる
nr
? script to run ›
❯   dev - run-p dev:next dev:path
    dev:next - node ./server/server.js
    dev:path - pathpida --ignorePath .gitignore --watch
    build - pathpida --ignorePath .gitignore && next build
    start - next start
    lint - next lint
    prettier - prettier --write .
    storybook - start-storybook -p 6006
    build-storybook - build-storybook

# 直前のコマンドをrerunする
nr -

# npx,yarn dlxに該当する実行する系のやつ
nix vitest
```

### execulte系
```bash
nlx vitest

# npx vitest
# yarn dlx vitest
# pnpm dlx vitest
# bunx vitest
# deno run npm:vitest
```

### upgrade系
```bash
nup

# npm upgrade
# yarn upgrade (Yarn 1)
# yarn up (Yarn Berry)
# pnpm update
# bun update
# deno upgrade
```

### uninstall系
```bash
nun webpack

# npm uninstall webpack
# yarn remove webpack
# pnpm remove webpack
# bun remove webpack
# deno remove webpack
```

### clean install系
```bash
nci

# npm ci
# yarn install --frozen-lockfile
# pnpm install --frozen-lockfile
# bun install --frozen-lockfile
# deno cache --reload
```