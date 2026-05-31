# Neovim Keymaps

`<Leader>` = `Space`

---

## 基本操作

| キー | モード | 動作 |
|---|---|---|
| `jj` | Insert | Escに戻る |
| `x` | Normal | 文字削除（レジスタ汚さない） |
| `j` / `k` | Normal | 折り返し行単位で移動 |
| `Shift+H` | Normal/Visual | 行頭へ |
| `Shift+L` | Normal/Visual | 行末へ |
| `+` / `-` | Normal | 数値を増減 |
| `Ctrl+h/j/k/l` | Insert | カーソル移動（左/下/上/右） |

---

## ウィンドウ / バッファ管理

| キー | 動作 |
|---|---|
| `<Leader>s` | 水平分割 |
| `<Leader>v` | 垂直分割 |
| `<Leader>h/j/k/l` | ウィンドウ間移動 |
| `<Leader>p` | 前のバッファ |
| `<Leader>n` | 次のバッファ |
| `<Leader>x` | バッファを閉じる |

---

## LSP

| キー | 動作 |
|---|---|
| `K` | ホバー表示 |
| `gd` | 定義へジャンプ |
| `gD` | 宣言へジャンプ |
| `gi` | 実装へジャンプ |
| `gt` | 型定義へジャンプ |
| `gr` | 参照一覧 |
| `gn` | リネーム |
| `ga` / `<Leader>ca` | コードアクション |
| `ge` | エラー詳細表示 |
| `g]` / `g[` | 次/前のエラーへ |
| `gf` | フォーマット（保存時自動実行） |

---

## 補完 (blink.cmp)

| キー | 動作 |
|---|---|
| `Tab` | 次の候補 / スニペット前進 |
| `Shift+Tab` | 前の候補 / スニペット後退 |
| `Enter` | 確定 |
| `Ctrl+Space` | 補完表示 / ドキュメント表示切替 |
| `Ctrl+e` | 補完を閉じる |

---

## Telescope（ファジー検索）

| キー | 動作 |
|---|---|
| `<Leader>ff` | ファイル検索 |
| `<Leader>fg` | ライブgrep（テキスト検索） |
| `<Leader>fb` | バッファ一覧 |
| `<Leader>fh` | ヘルプタグ検索 |
| `<Leader>fs` | 文字列指定grep |
| `<Leader>fo` | 現在バッファ内検索 |
| `<Leader>fe` | ファイルブラウザ |

### Telescope 内操作

| キー | 動作 |
|---|---|
| `Ctrl+j` / `Ctrl+k` | 候補を上下移動 |
| `Ctrl+v` | 垂直分割で開く |
| `Ctrl+s` | 水平分割で開く |
| `Ctrl+t` | 新しいタブで開く |
| `Ctrl+h` | キーマップヒント表示 |
| `q` | 閉じる（Normalモード） |

---

## Neo-tree（ファイラー）

| キー | 動作 |
|---|---|
| `<Leader>e` | Neo-tree 開く/閉じる |

### Neo-tree 内操作

| キー | 動作 |
|---|---|
| `Enter` | ファイルを開く |
| `Tab` | 垂直分割で開く |
| `Ctrl+t` | 新しいタブで開く |
| `c` | ファイル/ディレクトリ追加 |
| `C` | ディレクトリ追加 |
| `r` | リネーム |
| `d` | 削除 |

---

## Git (gitsigns)

| キー | 動作 |
|---|---|
| `]c` | 次の変更箇所(hunk)へ |
| `[c` | 前の変更箇所(hunk)へ |
| `<Leader>hs` | hunkをステージ |
| `<Leader>hr` | hunkをリセット |
| `<Leader>hS` | バッファ全体をステージ |
| `<Leader>hu` | ステージを取り消し |
| `<Leader>hR` | バッファ全体をリセット |
| `<Leader>hp` | hunkをプレビュー |

## Git (diffview)

| キー | 動作 |
|---|---|
| `<Leader>gd` | Diffview を開く |
| `<Leader>gq` | Diffview を閉じる |
| `<Leader>gh` | 現在ファイルの変更履歴 |
| `<Leader>gl` | Git グラフを表示 |

---

## ターミナル (toggleterm)

| キー | 動作 |
|---|---|
| `Ctrl+j` | フローティングターミナル 開く/閉じる |

---

## Surround (nvim-surround)

| コマンド | 変換例 |
|---|---|
| `ysiw)` | `word` → `(word)` |
| `ys$"` | カーソルから行末を `"..."` で囲む |
| `ds]` | `[text]` → `text` |
| `dst` | `<b>text</b>` → `text` |
| `cs'"` | `'text'` → `"text"` |
| `dsf` | `func(args)` → `args` |

---

## UI / その他

| キー | 動作 |
|---|---|
| `<Leader>;` | Dropbar: シンボル選択（パンくず） |
| `<Leader>Nh` | Noice: 通知履歴 |
| `<Leader>Nl` | Noice: 最後のメッセージ |
