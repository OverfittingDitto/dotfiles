-- diffview.nvim の設定
return {
	"sindrets/diffview.nvim",
	-- コマンド実行時にロード
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
	config = function()
		require("diffview").setup({
			-- デフォルト設定でも十分優秀ですが、お好みでカスタマイズ可能
			-- 例: ファイルパネルの幅など
			-- file_panel = {
			--   width = 35,
			-- },
		})

		-- キーマップ
		local map = vim.keymap.set
		map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>", { desc = "Diffview Open" })
		map("n", "<leader>gq", "<cmd>DiffviewClose<CR>", { desc = "Diffview Close" })
		map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "Diffview File History" })
	end,
}
