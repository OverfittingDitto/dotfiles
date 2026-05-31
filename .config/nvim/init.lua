-- =============================================================================
-- Simple & Minimal Neovim Config (Neovim v0.12+)
-- =============================================================================

-- =============================================================================
-- 1. プラグイン登録 (vim.pack)
-- =============================================================================

vim.pack.add({
    -- 補完
    "https://github.com/Saghen/blink.cmp",
    "https://github.com/Saghen/blink.lib",

    -- AI インライン補完（有効化する場合はコメント解除）
    -- "https://github.com/supermaven-inc/supermaven-nvim",

    -- Git
    "https://github.com/sindrets/diffview.nvim",
    "https://github.com/lewis6991/gitsigns.nvim",

    -- LSP
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",

    -- Treesitter（コミュニティフォーク版 / 要 tree-sitter CLI）
    "https://github.com/neovim-treesitter/nvim-treesitter",
    "https://github.com/neovim-treesitter/treesitter-parser-registry",

    -- ファイル操作・検索・ジャンプ
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/folke/flash.nvim",

    -- コーディング支援
    "https://github.com/altermo/ultimate-autopair.nvim",
    -- "https://github.com/echasnovski/mini.nvim",
    "https://github.com/stevearc/conform.nvim",

    -- Terminal
    "https://github.com/akinsho/toggleterm.nvim",

    -- UI・外観
    "https://github.com/catppuccin/nvim",
    "https://github.com/nvim-lualine/lualine.nvim",
    "https://github.com/akinsho/bufferline.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/shellRaining/hlchunk.nvim",

    -- Tiny UI シリーズ
    "https://github.com/rachartier/tiny-cmdline.nvim",
    "https://github.com/rachartier/tiny-code-action.nvim",
    "https://github.com/rachartier/tiny-inline-diagnostic.nvim",
})

-- =============================================================================
-- 2. 基本オプション
-- =============================================================================

local opt          = vim.opt

-- 表示
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.termguicolors  = true
opt.signcolumn     = "yes"
opt.wrap           = true
opt.winblend       = 0
opt.pumblend       = 0

-- 編集
opt.clipboard      = "unnamedplus"
opt.autoread       = true
opt.swapfile       = false
opt.hidden         = true
opt.virtualedit    = "block"
opt.autoindent     = true
opt.expandtab      = true
opt.tabstop        = 4
opt.shiftwidth     = 4

-- 検索
opt.hlsearch       = true
opt.incsearch      = true
opt.ignorecase     = true
opt.smartcase      = true

-- UI
vim.o.mouse        = "a"
vim.o.cmdheight    = 0
vim.o.guicursor    = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
vim.g.mapleader    = " "

-- =============================================================================
-- 3. キーマップ
-- =============================================================================

local map          = vim.keymap.set

-- 編集
map("i", "jj", "<ESC>", { silent = true, desc = "Escape insert mode" })
map("n", "x", '"_x', { silent = true, desc = "Delete without yank" })

-- ビジュアルモードで選択範囲をペーストで上書きした際、ヤンク（コピー）履歴を汚さない
map("x", "p", [["_dP]], { desc = "Paste over selection without losing yanked text" })

-- インサートモードのCtrl+cを、完全にEscキーと同じ挙動にする
map("i", "<C-c>", "<Esc>")

-- ノーマルモードのEscで、検索後のハイライトを消去する
map("n", "<Esc>", ":nohl<CR>", { silent = true, desc = "Clear search highlighting" })

-- カーソル下の単語を取得し、ファイル全体で一括置換するコマンドを自動入力
map("n", "<leader>%s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word cursor is on" })

-- 移動（折り返し行対応）
map("n", "j", "gj", { desc = "Move down by display line" })
map("n", "k", "gk", { desc = "Move up by display line" })

-- 半ページスクロール（Ctrl+d / Ctrl+u）時に、カーソルを常に画面中央に保つ
map("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })

-- 検索で「次へ(n)」「前へ(N)」移動する際、カーソルを画面中央に保ち、折りたたみを展開する
map("n", "n", "nzzzv", { desc = "Next search result cursor centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result cursor centered" })

-- ウィンドウ
map("n", "<Leader>s", ":split<CR><C-w>w", { silent = true, desc = "Split horizontal" })
map("n", "<Leader>v", ":vsplit<CR><C-w>w", { silent = true, desc = "Split vertical" })
map("n", "<Leader>h", "<C-w>h", { silent = true, desc = "Window left" })
map("n", "<Leader>j", "<C-w>j", { silent = true, desc = "Window down" })
map("n", "<Leader>k", "<C-w>k", { silent = true, desc = "Window up" })
map("n", "<Leader>l", "<C-w>l", { silent = true, desc = "Window right" })

-- バッファ
map("n", "<Leader>p", ":bprevious<CR>", { silent = true, desc = "Prev buffer" })
map("n", "<Leader>n", ":bnext<CR>", { silent = true, desc = "Next buffer" })
map("n", "<Leader>x", ":bdelete<CR>", { silent = true, desc = "Close buffer" })

-- =============================================================================
-- 4. Diagnostic 設定（0.12 準拠 / サイン設定は config 経由のみ）
-- =============================================================================

vim.diagnostic.config({
    severity_sort = true,
    float         = { border = "rounded", source = "if_many" },
    underline     = { severity = vim.diagnostic.severity.ERROR },
    virtual_text  = false, -- tiny-inline-diagnostic に委譲
    signs         = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN]  = "󰀪 ",
            [vim.diagnostic.severity.INFO]  = "󰋽 ",
            [vim.diagnostic.severity.HINT]  = "󰌶 ",
        },
    },
})

-- =============================================================================
-- 5. プラグイン設定
-- =============================================================================

-- ◆ カラースキーム
require("catppuccin").setup({ transparent_background = true })
vim.cmd.colorscheme("catppuccin-frappe")
-- vim.cmd.colorscheme("catppuccin-mocha")

-- ◆ 実験的 UI2（0.12 新コア UI）
require("vim._core.ui2").enable()

-- ◆ tiny-cmdline（中央コマンドライン）
require("tiny-cmdline").setup({
    on_reposition = require("tiny-cmdline").adapters.blink,
    native_types  = {},
    window        = { border = "rounded", row = "50%", col = "50%" },
})

-- ◆ tiny-code-action（LSP コードアクション）
require("tiny-code-action").setup({ backend = "delta" })
map("n", "<leader>ca", function() require("tiny-code-action").code_action() end, { silent = true })

-- ◆ tiny-inline-diagnostic（インラインエラー）
require("tiny-inline-diagnostic").setup()

-- ◆ Mason（LSP サーバー管理）
require("mason").setup()

-- ◆ blink.cmp（自動補完）
local cmp = require("blink.cmp")
cmp.build():wait(60000)
cmp.setup({
    keymap     = {
        ["<Tab>"]   = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<CR>"]    = { "accept", "fallback" },
    },
    sources    = { default = { "lsp", "path", "snippets", "buffer" } },
    completion = {
        list          = {
            selection = {
                preselect = false,
                auto_insert = false,
            },
        },
        menu          = { border = "rounded" },
        documentation = { auto_show = true, window = { border = "rounded" } },
        ghost_text    = { enabled = true },
    },
})

-- ◆ Supermaven（AI インライン補完）
-- blink.cmp と共存可。<C-l> で提案を確定。
-- 有効化する場合は pack.add の supermaven 行も合わせてコメント解除すること。
--
-- require("supermaven-nvim").setup({ disable_keymaps = true })
-- map("i", "<C-l>", function()
--     require("supermaven-nvim.completion_preview").on_accept_suggestion()
-- end, { silent = true, desc = "Accept Supermaven suggestion" })

-- ◆ Diffview（Git diff ビューア）
require("diffview").setup({
    watch_index = true,
    file_panel  = { win_config = { type = "float", width = 30, height = 10 } },
    view        = { default = { layout = "diff2_vertical" } },
})

-- ◆ Gitsigns（行ごとの Git 状態表示）
require("gitsigns").setup()

-- ◆ Claude Code 連動：Git 変更検知で Diffview を自動展開
-- tmux で Claude が編集した直後に差分を自動表示したい場合に有効化する。
-- Diffview が既に開いていれば Refresh、未開なら DiffviewOpen を実行。
--
-- vim.api.nvim_create_autocmd("User", {
--     pattern  = "GitSignsUpdate",
--     callback = function()
--         if vim.fn.mode() ~= "n" then return end
--         vim.cmd("checktime")
--         local diffview_open = false
--         for _, win in ipairs(vim.api.nvim_list_wins()) do
--             if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "DiffviewFiles" then
--                 diffview_open = true
--                 break
--             end
--         end
--         vim.cmd(diffview_open and "DiffviewRefresh" or "DiffviewOpen")
--     end,
-- })

-- ◆ Oil（ファイラー）
-- `-` で開く/閉じるをトグル。親ディレクトリへは ".." を選択する。
require("oil").setup({
    default_file_explorer = true,
    view_options = { show_hidden = true },
    keymaps = {
        ["-"] = "actions.close", -- Oil 内では `-` で閉じる (デフォは parent)
    },
})
map("n", "-", "<CMD>Oil<CR>", { desc = "Open Oil" })

require("toggleterm").setup({
    open_mapping = [[<C-j>]],
    direction = "float",
    float_opts = {
        border = "curved",
        width = 150,
        height = 40,
        winblend = 0,
    },
    hide_numbers = true,
    shade_terminals = true,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
})

-- ◆ Telescope（ファジーファインダー）
local tb = require("telescope.builtin")
map("n", "<leader>ff", tb.find_files, { desc = "Find files" })
map("n", "<leader>fg", tb.live_grep, { desc = "Live grep" })
map("n", "<leader>fb", tb.buffers, { desc = "Buffers" })

-- ◆ Flash（カーソルジャンプ）
require("flash").setup()
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })

-- ◆ Ultimate Autopair（括弧補完）
require("ultimate-autopair").setup()

-- ◆ mini.comment（gc でコメントアウト）
-- require("mini.comment").setup()

-- ◆ mini.surround（テキストオブジェクト囲み操作）
-- flash.nvim が s を使うため、ys / ds / cs にリマップして共存。
--
-- require("mini.surround").setup({
--     mappings = {
--         add     = "ys", -- ysiw" → 単語を " で囲む
--         delete  = "ds", -- ds"   → " を削除
--         replace = "cs", -- cs"'  → " を ' に置換
--     },
-- })

-- ◆ Conform（フォーマッター）
require("conform").setup({
    formatters_by_ft = {
        lua        = { "stylua" },
        rust       = { "rustfmt" },
        python     = { "ruff_format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html       = { "prettier" },
        css        = { "prettier" },
        go         = { "gofmt" },
    },
    format_on_save = { lsp_format = "fallback", timeout_ms = 500 },
})

-- ◆ Lualine（ステータスライン）
require("lualine").setup({
    options = {
        -- powerline 風セパレータ（シャープ版は下の行をコメント解除）
        section_separators   = { left = "", right = "" },
        component_separators = {},
        -- section_separators   = { left = "", right = "" },
        -- component_separators = { left = "", right = "" },
        globalstatus         = true,
        theme                = "auto",
    },
    sections = {
        -- powerline 風モード表示（丸みのある版は下をコメント解除）
        lualine_a = { "mode" },
        -- lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
        lualine_b = { "filename", "branch" },
        lualine_c = {
            "%=", -- 以降を中央寄せ
            { "diff", symbols = { added = " ", modified = " ", removed = " " } },
            { "diagnostics", symbols = { error = "󰅚 ", warn = "󰀪 ", info = "󰋽 ", hint = "󰌶 " } },
        },
        lualine_x = { "encoding", "filetype" },
        lualine_y = { "lsp_status" },
        lualine_z = { "location" },
        -- lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
    },
    inactive_sections = {},
})

-- ◆ Bufferline（バッファタブ）
require("bufferline").setup({
    options = { mode = "buffers", diagnostics = "nvim_lsp" },
})

-- ◆ hlchunk（インデント・チャンク表示）
require("hlchunk").setup({
    chunk    = { enable = true },
    indent   = { enable = true },
    line_num = { enable = true },
})

-- =============================================================================
-- 6. LSP 設定（Neovim 0.12 ネイティブ）
-- =============================================================================
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        map("n", "gd", vim.lsp.buf.definition, opts)
        map("n", "K", vim.lsp.buf.hover, opts)
        map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    end,
})

vim.lsp.enable("gopls")         -- Go
vim.lsp.enable("ts_ls")         -- TypeScript / JavaScript
vim.lsp.enable("rust_analyzer") -- Rust
vim.lsp.enable("lua_ls")        -- Lua
