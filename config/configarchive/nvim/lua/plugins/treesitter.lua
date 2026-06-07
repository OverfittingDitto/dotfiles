return {
	-- nvim-treesitter: Neovim 0.12ではハイライトはコアが担当
	-- このプラグインはパーサーのインストール管理のみに使用
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = "VeryLazy",
		config = function()
			require("nvim-treesitter.install").prefer_gitfiles = false
			vim.treesitter.language.add = vim.treesitter.language.add or function() end
			-- パーサーのインストール管理のみ (highlight/indentはNeovim 0.12コアが担当)
			require("nvim-treesitter.install").ensure_installed({
				"javascript",
				"typescript",
				"tsx",
				"html",
				"css",
				"json",
				"rust",
				"go",
				"python",
				"toml",
				"yaml",
				"markdown",
				"markdown_inline",
				"sql",
				"regex",
				"bash",
				"lua",
			})
		end,
	},

	-- スクロール時に関数名などを上部に表示
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "VeryLazy",
		opts = {
			max_lines = 3,
		},
	},

	-- 括弧の虹色ハイライト
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "VeryLazy",
		config = function()
			require("rainbow-delimiters.setup").setup({})
		end,
	},
}
