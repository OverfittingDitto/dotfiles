return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- アイコン表示に必要
	event = { "VeryLazy" },
	config = function()
		require("lualine").setup({
			options = {
				section_separators = { left = "", right = "" },
				-- component_separators = { left = "", right = "" },
				component_separators = {},
				globalstatus = true,
				theme = "auto", --とすれば自動検出も可能
			},
			sections = {
				-- lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
				lualine_a = { "mode" },
				lualine_b = { "filename", "branch" },
				lualine_c = {
					"'%='",
					{
						"diff",
						symbols = { added = " ", modified = " ", removed = " " },
						separator = "     ",
					},
					{
						"diagnostics",
						symbols = { error = "󰅚 ", warn = "󰀪 ", info = "󰋽 ", hint = "󰌶 " },
					},
				},
				lualine_x = { "encoding", "filetype" },
				lualine_y = { "lsp_status" },
				lualine_z = { "location" },
				-- lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
		})
	end,
}
