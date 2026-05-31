return {
	{
		"petertriho/nvim-scrollbar",
		event = "VeryLazy", -- Neovim起動完了後に遅延ロード
		config = function()
			require("scrollbar").setup()
		end,
	},
}
