return {
	"akinsho/toggleterm.nvim",
	version = "*",
	event = "VeryLazy",
	config = function()
		-- local colors = require("catppuccin.palettes").get_palette("mocha")
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
			-- highlights = {
			-- 	NormalFloat = {
			-- 		guibg = colors.base,
			-- 	},
			-- 	FloatBorder = {
			-- 		guifg = colors.blue, -- 枠線の色を青に
			-- 		guibg = colors.base, -- 枠線の背景はターミナルと同じ色に
			-- 	},
			-- },
		})
	end,
}
