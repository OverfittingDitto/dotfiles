-- gitsigns.nvim の設定
return {
	"lewis6991/gitsigns.nvim",
	-- ファイルを開いたときやGitリポジトリが変更されたときにロード
	event = { "BufReadPre", "BufNewFile", "DirChanged" },
	config = function()
		require("gitsigns").setup({
			-- アイコン設定
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			-- 現在行の変更内容をリアルタイムでプレビュー
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text_pos = "eol", -- 行末に表示
				delay = 500,
			},
			-- キーマップ
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns
				local map = vim.keymap.set

				-- Hunk（変更箇所）間の移動
				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Next Hunk" })

				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Prev Hunk" })

				-- Hunkに対する操作
				map("n", "<leader>hs", gs.stage_hunk, { buffer = bufnr, desc = "Stage Hunk" })
				map("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr, desc = "Reset Hunk" })
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { buffer = bufnr, desc = "Stage Hunk" })
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { buffer = bufnr, desc = "Reset Hunk" })
				map("n", "<leader>hS", gs.stage_buffer, { buffer = bufnr, desc = "Stage Buffer" })
				map("n", "<leader>hu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo Stage Hunk" })
				map("n", "<leader>hR", gs.reset_buffer, { buffer = bufnr, desc = "Reset Buffer" })
				map("n", "<leader>hp", gs.preview_hunk, { buffer = bufnr, desc = "Preview Hunk" })
			end,
		})
	end,
}
