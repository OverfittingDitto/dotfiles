Todo list

## 未対応

[] 起動高速化のためのプラグイン読み込み最適化

check cmd `vim --startuptime ~/nvim.log +q`

- ほとんどのプラグインを起動時に読み込んでるからなかなか遅い

[] neotreeの表示範囲（横幅）の調整

ちょっと長すぎ？

[] neotreeのカーソルハイライトを変更する

[] virtual_lines への移行検討（Neovim 0.12）
- `virtual_lines = { current_line = true }` でカーソル行のみ診断表示
- 現状の virtual_text でも問題なし、好みで変更

## 完了

[x] colorizerの設定や挙動を調べる。
デフォルトですべてのファイルに適応されそうだが、少なくともLuaファイルには適応されていない。
コマンドからbufferにアタッチしたら適応された。

[x] LSP周り見直し（2026-05-17）
- conform.nvim: lsp_fallback → lsp_format に修正
- LSPキーマップを LspAttach に移動（グローバルスコープ解消）
- ts_ls (TypeScript LSP) を追加
- mason-lspconfig に ensure_installed を追加
- after/lsp/ts_ls.lua を新規作成

[x] Claude Code × Neovim 連携（2026-05-17）
- claudecode.nvim を導入（coder/claudecode.nvim）
- tmux ペイン運用 + diff ビューア中心の構成
- <leader>as: 選択送信 / <leader>ad: Accept / <leader>aD: Deny
