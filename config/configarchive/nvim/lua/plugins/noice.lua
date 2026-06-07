return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		-- nvim-notifyの通知もnoiceで表示したい場合に必要
		"rcarriga/nvim-notify",
	},
	config = function()
		require("noice").setup({
			lsp = {
				-- LSPの進捗メッセージなどを、デフォルトのUIではなくnoiceで表示する
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			-- 便利な設定プリセット
			presets = {
				bottom_search = true, -- 検索結果を画面下に表示
				-- command_palette = true, -- コマンドパレットUIを有効化
				long_message_to_split = true, -- 長いメッセージを分割ウィンドウで表示
				inc_rename = false, -- Neovim 0.10.0のinc_renameと競合するためfalseに
				lsp_doc_border = false, -- LSPのドキュメントに枠線をつけるか
			},
		})

		-- nvim-notifyのメッセージもNoiceにリダイレクト
		require("notify").setup({
			background_colour = "#000000",
			render = "minimal",
		})
		vim.notify = require("notify")

		-- キーマップ
		local map = vim.keymap.set
		map("n", "<leader>Nh", function()
			require("noice").cmd("history")
		end, { desc = "Noice History" })
		map("n", "<leader>Nl", function()
			require("noice").cmd("last")
		end, { desc = "Noice Last Message" })
	end,
}
