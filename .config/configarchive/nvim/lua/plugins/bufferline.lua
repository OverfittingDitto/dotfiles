return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	event = { "VeryLazy" },
	opts = {
		options = {
			mode = "buffers",
			-- diagnostics = "nvim_lsp", -- LSPのエラーなどを表示
			offsets = {
				{
					filetype = "neo-tree",
					text = "󱀲 ",
					separator = true,
					text_align = "center",
				},
			},
		},
	},
}
