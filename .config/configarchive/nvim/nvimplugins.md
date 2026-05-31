## Neovim plugins

### プラグインマネージャ
[x] lazy.nvim

### ファジーファインダー
[x] telescope.nvim

[x] telescope-fzf-native.nvim

[x] telescope-file-browser.nvim

[x] telescope-ui-select.nvim

[ ] ~~smart-open.nvim~~ (まだ使わなそう)

### ハイライト
[x] nvim-treesitter
    なんかtextobjがうまく動いてなさそう

[x] nvim-treesitter-context

[ ] nvim-treesitter-textsubjects

### UI
[x] lualine.nvim

[x] bufferline.nvim

[x] hlchunk.nvim

[x] noice.nvim

[x] notify.nvim

[x] nvim-scrollbar

[x] which-key.nvim

[ ] ~~fidget.nvim~~ (noice.nvimと機能が重複するため不要)

### ファイルエクスプローラー
[x] neo-tree.nvim

[ ] ~~nvim-tree.lua~~ (neo-treeを選択)

### Git
[x] gitsigns.nvim

[x] diffview.nvim

[x] gitgraph.nvim

[x] toggleterm (lazygit用)

### 言語サポート (LSP)
[x] nvim-lspconfig

[x] mason.nvim

[x] mason-lspconfig.nvim

[x] conform.nvim (フォーマッター)

[x] nvim-lint (リンター)

[ ] ~~none-ls.nvim~~ (開発終了のためconform/nvim-lintへ移行)

[ ] ~~mason-null-ls.nvim~~ (上記に同じ)

### 補完 (Cmp)
[x] Blink.cmp (All in Cmp)

[ ]  ~~nvim-cmp~~

[ ] ~~cmp-spell~~

[ ] ~~cmp-buffer~~

[ ] ~~cmp-cmdline~~

[ ] ~~cmp-nvim-lsp~~

[ ] ~~cmp-path~~

[x] lspkind.nvim

[x] LuaSnip

[ ] ~~cmp_luasnip~~

### ユーティリティ関係
[x] nvim-autopairs

[ ] ~~Comment.nvim~~ (標準機能で十分そう)

[x] todo-comments.nvim

[ ] ~~dial.nvim~~ (これも標準でよさそう あんまりメジャーではなさそうだし)

[x] nvim-surround

[x] dropbar.nvim (パンくずリスト表示)

[x] eyeliner.nvim (f motion enhance)

[x] auto-session
[] Neoscroll
[] grug-far
[] trouble
## 言語サポートツール一覧

### Rust

- **LSP**: rust-analyzer  
  `rustup component add rust-analyzer`

- **Formatter**: rustfmt  
  `rustup component add rustfmt`

- **Linter**: clippy  
  `rustup component add clippy`

- **前提**: Rust本体  
  `mise use -g rust@latest`


### Go

- **LSP**: gopls  
  `go install golang.org/x/tools/gopls@latest`

- **Formatter**: gofmt / goimports  
  `gofmt` は標準搭載  
  `go install golang.org/x/tools/cmd/goimports@latest`

- **Linter**: golangci-lint  
  `brew install golangci-lint`  
  または  
  `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest`

- **前提**: Go本体  
  `mise use -g go@latest`


### Python

- **LSP**: pyright  
  `uv pip install pyright`
ruffにLSPが統合されているのでそっちを使うほうがシンプルかも

- **Formatter**: ruff format  
  `uv pip install ruff`

- **Linter**: ruff  
  `uv pip install ruff`

- **前提**: Python本体 + uv  
  `mise use -g python@latest`  
  `mise use -g uv@latest`


### JavaScript / TypeScript

- **LSP**: typescript-language-server  
  `npm install -g typescript-language-server typescript`

- **Formatter**: prettier  
  `npm install -g prettier`

- **Linter**: eslint  
  `npm install -g eslint`

- **前提**: Node.js本体  
  `mise use -g node@latest`


### Lua

- **LSP**: lua-language-server  
  `brew install lua-language-server`

- **Formatter**: stylua  
  `brew install stylua`


### HTML / CSS

- **LSP**: vscode-langservers-extracted  
  `npm install -g vscode-langservers-extracted`


### JSON

- **Formatter**: prettier（JS/TSでインストール済み）

