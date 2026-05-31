return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for Neovim
		-- Mason must be loaded before its dependents so we need to set it up here.
		-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
		"mason-org/mason.nvim",
		"mason-org/mason-lspconfig.nvim",
		-- 'WhoIsSethDaniel/mason-tool-installer.nvim',

		-- Allows extra capabilities provided by blink.cmp
		"saghen/blink.cmp",
	},
	config = function()
		-- === 1. LSPが起動した「後」の共通処理を定義 ===
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
			callback = function(ev)
				local opts = { buffer = ev.buf }
				local extend = function(desc)
					return vim.tbl_extend("force", opts, { desc = desc })
				end

				-- ナビゲーション
				vim.keymap.set("n", "K",  vim.lsp.buf.hover,           extend("LSP: Hover"))
				vim.keymap.set("n", "gd", vim.lsp.buf.definition,      extend("LSP: Go to Definition"))
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration,     extend("LSP: Go to Declaration"))
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation,  extend("LSP: Go to Implementation"))
				vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, extend("LSP: Go to Type Definition"))

				-- アクション (gr系はNeovim 0.12ビルトインと競合するため gn/ga を使用)
				vim.keymap.set("n", "gn",         vim.lsp.buf.rename,      extend("LSP: Rename"))
				vim.keymap.set("n", "ga",         vim.lsp.buf.code_action, extend("LSP: Code Action"))
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, extend("LSP: Code Action"))

				-- 診断
				vim.keymap.set("n", "ge", vim.diagnostic.open_float, extend("LSP: Show Diagnostics"))
				vim.keymap.set("n", "g]", vim.diagnostic.goto_next,  extend("LSP: Next Diagnostic"))
				vim.keymap.set("n", "g[", vim.diagnostic.goto_prev,  extend("LSP: Prev Diagnostic"))

				-- フォーマット (conform経由、LSPフォールバックあり)
				vim.keymap.set("n", "gf", function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end, extend("LSP: Format"))
			end,
		})

		-- === 2. 使用するLSPサーバーを「有効化」する ===
		local servers = {
			-- miseで管理
			"rust_analyzer",
			"pyright",
			-- masonで管理
			"lua_ls",
			"cssls",
			"html",
			"jsonls",
			"marksman",
			"taplo",
			"ts_ls",
		}
		vim.lsp.enable(servers)
	end,
}
