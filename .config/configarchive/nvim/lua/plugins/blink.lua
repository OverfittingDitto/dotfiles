return {
	"saghen/blink.cmp",
	dependencies = {
		"L3MON4D3/LuaSnip", -- スニペットエンジン
		"rafamadriz/friendly-snippets", -- スニペット集
		-- "onsails/lspkind.nvim",
	},
	version = "*",
	-- event = { "InsertEnter", "CmdLineEnter" },
	event = { "VeryLazy" },
	-- config = function(_, opts)
	-- 	local ls = require("luasnip")
	-- 	require("luasnip.loaders.from_vscode").lazy_load()
	-- 	ls.add_snippets("all", require("utils.snippets"))
	-- 	require("blink.cmp").setup(opts)
	-- end,
	opts = {
		completion = {
			-- 補完メニューの挙動設定
			menu = { border = "rounded" },
			-- auto_select = false, -- 自動で最初の候補を選択しない
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 500,
				window = { border = "rounded" },
			},
			list = {
				selection = {
					preselect = false,
					auto_insert = false,
				},
			},
		},
		signature = { window = { border = "rounded" } },
		keymap = {
			-- キーマッピング設定
			["<Tab>"] = {
				"select_next",
				"snippet_forward",
				"fallback",
			},
			["<S-Tab>"] = {
				"select_prev",
				"snippet_backward",
				"fallback",
			},
			["<CR>"] = { "accept", "fallback" },
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },
		},

		sources = {

			-- デフォルトで有効にするソース
			default = { "lsp", "buffer", "path", "snippets" },
			-- 特定のファイルに対して上書き設定
			per_filetype = {
				markdown = { "snippets", "lsp", "path" },
				mdx = { "snippets", "lsp", "path" },
			},
		},
		appearance = {
			-- 外観の設定
			nerd_font_variant = "mono",
		},
		snippets = {
			preset = "luasnip",
		},
	},
	-- opts_extend = { "sources.default" },
}
