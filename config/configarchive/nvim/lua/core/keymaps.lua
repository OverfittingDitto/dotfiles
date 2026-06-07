-- /nvim/lua/core/keymaps.lua
-- Neovimのコアキーマップ設定

-- APIのエイリアスを設定
local map = vim.keymap.set

-- [[ 基本的な編集操作 ]]

-- Insertモードで jj を押すと Esc になる
map("i", "jj", "<ESC>", { noremap = true, silent = true, desc = "Escape insert mode" })

-- Insertモードでのカーソル移動
map("i", "<C-k>", "<Up>", { desc = "Move cursor up" })
map("i", "<C-j>", "<Down>", { desc = "Move cursor down" })
map("i", "<C-h>", "<Left>", { desc = "Move cursor left" })
map("i", "<C-l>", "<Right>", { desc = "Move cursor right" })

-- レジスタを汚さずに文字を削除
map("n", "x", '"_x', { noremap = true, silent = true, desc = "Delete character without yanking" })

-- [[ 移動 ]]

-- 折り返し行を1行として移動
map("n", "j", "gj", { noremap = true, desc = "Move down by display line" })
map("n", "k", "gk", { noremap = true, desc = "Move up by display line" })

-- 行頭・行末への移動
map({ "n", "v" }, "<S-h>", "^", { noremap = true, desc = "Move to start of line" })
map({ "n", "v" }, "<S-l>", "$", { noremap = true, desc = "Move to end of line" })

-- 数値の増減
map("n", "+", "<C-a>", { noremap = true, silent = true, desc = "Increment number" })
map("n", "-", "<C-x>", { noremap = true, silent = true, desc = "Decrement number" })

-- [[ ウィンドウ管理 ]]

-- 画面分割
map("n", "<Leader>s", ":split<Return><C-w>w", { noremap = true, silent = true, desc = "Split window horizontally" })
map("n", "<Leader>v", ":vsplit<Return><C-w>w", { noremap = true, silent = true, desc = "Split window vertically" })

-- アクティブウィンドウの移動
map("n", "<Leader>h", "<C-w>h", { noremap = true, silent = true, desc = "Move to left window" })
map("n", "<Leader>k", "<C-w>k", { noremap = true, silent = true, desc = "Move to upper window" })
map("n", "<Leader>j", "<C-w>j", { noremap = true, silent = true, desc = "Move to lower window" })
map("n", "<Leader>l", "<C-w>l", { noremap = true, silent = true, desc = "Move to right window" })

-- [[ バッファ管理 ]]

-- バッファ移動
map("n", "<Leader>p", ":bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
map("n", "<Leader>n", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
map("n", "<Leader>x", ":bdelete<CR>", { noremap = true, silent = true, desc = "Close buffer" })

-- LSP関連キーマップは lua/lsp/lspconfig.lua の LspAttach で定義
