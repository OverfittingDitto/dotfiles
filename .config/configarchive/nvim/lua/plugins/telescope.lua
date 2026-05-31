return {
	"nvim-telescope/telescope.nvim",
	-- branch = "0.1.x",
	dependencies = {
		{ "nvim-lua/plenary.nvim", lazy = true },
		-- fzf-nativeによる高速化
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			lazy = true,
		},
		-- ✨拡張機能を追加✨
		-- { "nvim-telescope/telescope-ui-select.nvim", lazy = true },
		{ "nvim-telescope/telescope-file-browser.nvim", lazy = true },
	},
	-- event = { "VeryLazy" },
	cmd = "Telescope",

	opts = {
		defaults = {
			layout_strategy = "flex",
			sorting_strategy = "ascending",
			mappings = {
				i = {
					["<C-j>"] = "move_selection_next",
					["<C-k>"] = "move_selection_previous",
					["<C-v>"] = "select_vertical",
					["<C-s>"] = "select_horizontal",
					["<C-t>"] = "select_tab",
					["<C-h>"] = "which_key",
				},
				n = {
					["q"] = "close",
					["<C-v>"] = "select_vertical",
					["<C-s>"] = "select_horizontal",
					["<C-t>"] = "select_tab",
				},
			},
			preview = {
				wrap_lines = true,
			},
			path_display = {
				filename_first = {
					reverse_directories = false,
				},
			},
			file_ignore_patterns = {
				"node_modules/",
				"__pycache__/",
				"%.pyc",
				"%.o",
				"%.a",
				"%.so",
				"%.class",
				"%.log",
				"%.zwc$", -- zshのキャッシュファイルを除外
				"target/", -- Rustのビルド成果物
				"dist/", -- 一般的なビルド成果物
				"build/", -- 一般的なビルド成果物
				"%.DS_Store",
				-- ユーザー設定から持ってきたもの
				"^.git/",
				"^.cache/",
				"^.zsh_sessions/",
				"Library/",
				"Parallels/",
				"Movies/",
				"Music/",
				"Dropbox/",
			},
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"-uu",
				"--hidden",
			},
		},
		-- ✨拡張機能の設定を追加✨
		extensions = {
			-- fzf-nativeを有効化
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
			-- ui-selectのテーマをTelescope本体と合わせる
			-- ["ui-select"] = {
			-- 	require("telescope.themes").get_dropdown({}),
			-- },
			-- file_browserの設定
			file_browser = {
				-- カレントディレクトリを基準に開く
				cwd = vim.fn.getcwd(),
				-- result で ls -l 表記を無効化
				display_stat = false,
			},
		},
	},

	-- キーマップは 'keys' テーブルで管理
	keys = {
		-- ファイル検索
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files({ hidden = true })
			end,
			desc = "Telescope: Find files",
		},
		-- ライブ検索
		{
			"<leader>fg",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Telescope: Live grep",
		},
		-- バッファ検索
		{
			"<leader>fb",
			function()
				require("telescope.builtin").buffers()
			end,
			desc = "Telescope: Find buffers",
		},
		-- ヘルプタグ検索
		{
			"<leader>fh",
			function()
				require("telescope.builtin").help_tags()
			end,
			desc = "Telescope: Find help tags",
		},
		-- カスタム文字列検索
		{
			"<leader>fs",
			function()
				require("telescope.builtin").grep_string({ search = vim.fn.input("Grep For > ") })
			end,
			desc = "Telescope: Grep for string",
		},
		-- カレントバッファ内ファジー検索
		{
			"<leader>fo",
			function()
				require("telescope.builtin").current_buffer_fuzzy_find()
			end,
			desc = "Telescope: Grep Current buffers",
		},
		-- ファイルブラウザ
		{
			"<leader>fe",
			function()
				require("telescope").extensions.file_browser.file_browser()
			end,
			desc = "Telescope: File Browser",
		},
	},

	-- 拡張機能をロードする
	-- config = function(_, opts)
	-- 	local telescope = require("telescope")
	-- 	telescope.setup(opts)
	-- 	-- ✨拡張機能をロード✨
	-- 	telescope.load_extension("fzf")
	-- 	telescope.load_extension("ui-select")
	-- 	telescope.load_extension("file_browser")
	-- end,
}
