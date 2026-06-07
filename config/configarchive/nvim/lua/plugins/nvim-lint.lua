-- リンター (nvim-lint) の設定
return {
	"mfussenegger/nvim-lint",
	-- ファイルを開いた後、保存した後、入力モードを抜けた後など、
	-- 非同期でリント処理を実行する
	event = { "BufWritePost", "BufReadPost", "InsertLeave" },
	config = function()
		local lint = require("lint")

		-- 使用するリンターをファイルタイプごとに指定
		-- ここにリストされているツールがPCにインストールされている必要がある
		lint.linters_by_ft = {
			rust = { "clippy" },
			-- go = { "golangci-lint" },
			python = { "ruff" },
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
		}

		-- lintを自動実行するためのautocmd
		vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("nvim-lint-autogroup", { clear = true }),
			callback = function()
				-- 現在のバッファに対してリントを試みる
				lint.try_lint()
			end,
		})
	end,
}
