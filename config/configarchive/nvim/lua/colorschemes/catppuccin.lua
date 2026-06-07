return {
	-- catppuccin theme config
	"catppuccin/nvim",
	lazy = false,
	name = "catppuccin",
	priority = 1000,
	config = function()
		require("catppuccin").setup({

			-- ここに渡したい設定を書く
			flavour = "mocha", -- macchiato, frappe, latte, mocha
			-- defaultで透明化しない
			transparent_background = true,
			integrations = {
				gitsigns = true,
				nvimtree = true,
				treesitter = true,
				notify = false,
				gitgraph = true,
				diffview = false,
			},
			-- その他、太字や斜体などの設定も可能
			-- styles = {
			--   comments = { "italic" },
			--   keywords = { "italic" },
			--   functions = {},
			--   variables = {},
			-- },
		})
		require("catppuccin").load()
	end,
}
