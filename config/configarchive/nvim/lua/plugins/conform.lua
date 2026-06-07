-- フォーマッター (conform.nvim) の設定
return {
	"stevearc/conform.nvim",
	-- ファイルを保存する直前にのみロードする
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	config = function()
		require("conform").setup({
			-- 使用するフォーマッターをファイルタイプごとに指定
			-- ここにリストされているツールがPCにインストールされている必要がある
			formatters_by_ft = {
				lua = { "stylua" },
				rust = { "rustfmt" },
				-- go = { "gofmt" },
				python = { "ruff_format" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
			},
			-- ファイル保存時に自動でフォーマットを実行する設定
			format_on_save = {
				-- LSPのフォーマット機能をフォールバックとして使用する
				lsp_format = "fallback",
				-- フォーマット処理のタイムアウト時間 (ミリ秒)
				timeout_ms = 500,
			},
		})
	end,
}
