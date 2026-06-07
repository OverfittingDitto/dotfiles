-- git-graph.nvim の設定
return {
	"isakbm/gitgraph.nvim",
	dependencies = { "sindrets/diffview.nvim" },
	opts = {
		git_cmd = "git",
		symbols = {
			merge_commit = "○",
			commit = "●",
			merge_commit_end = "○",
			commit_end = "●",

			-- Advanced symbols
			GVER = "│",
			GHOR = "─",
			GCLD = "╮",
			GCRD = "╭",
			GCLU = "╯",
			GCRU = "╰",
			GLRU = "┴",
			GLRD = "┬",
			GLUD = "┤",
			GRUD = "├",
			GFORKU = "┼",
			GFORKD = "┼",
			GRUDCD = "├",
			GRUDCU = "┡",
			GLUDCD = "┪",
			GLUDCU = "┩",
			GLRDCL = "┬",
			GLRDCR = "┬",
			GLRUCL = "┴",
			GLRUCR = "┴",
		},
		format = {
			-- timestamp = "%H:%M:%S %d-%m-%Y",
			timestamp = "%Y-%m-%d %H:%M:%S",
			fields = { "hash", "timestamp", "author", "branch_name", "tag" },
		},
		hooks = {
			-- Check diff of a commit
			on_select_commit = function(commit)
				vim.notify("DiffviewOpen " .. commit.hash .. "^!")
				vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
			end,
			-- Check diff from commit a -> commit b
			on_select_range_commit = function(from, to)
				vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
				vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
			end,
		},
	},
	keys = {
		{
			"<leader>gl",
			function()
				require("gitgraph").draw({}, { all = true, max_count = 5000 })
			end,
			desc = "GitGraph - Draw",
		},
	},
	config = function(_, opts)
		-- 1. プラグインのセットアップ
		require("gitgraph").setup(opts)

		-- 2. ハイライトグループをVSCode風の色に設定
		local set_hl = vim.api.nvim_set_hl
		-- コミット情報
		-- set_hl(0, "GitGraphHash", { fg = "#56B6C2" }) -- Cyan
		-- set_hl(0, "GitGraphTimestamp", { fg = "#6A9955" }) -- Green
		-- set_hl(0, "GitGraphAuthor", { fg = "#DCDCAA" }) -- Light Yellow
		-- set_hl(0, "GitGraphBranchName", { fg = "#C586C0", bold = true }) -- Magenta
		-- set_hl(0, "GitGraphBranchTag", { fg = "#FFD700", bold = true }) -- Gold
		set_hl(0, "GitGraphBranchMsg", { fg = "#FFFFFF", bold = true }) -- Gold

		-- ブランチの線の色 (VSCode GitGraph Extention color)
		set_hl(0, "GitGraphBranch1", { fg = "#a300d9" }) -- Purple
		set_hl(0, "GitGraphBranch2", { fg = "#0085d9" }) -- Blue
		set_hl(0, "GitGraphBranch3", { fg = "#d9008f" }) -- Red
		set_hl(0, "GitGraphBranch4", { fg = "#00d90a" }) -- Green
		set_hl(0, "GitGraphBranch5", { fg = "#d98500" }) -- Orange
	end,
}
