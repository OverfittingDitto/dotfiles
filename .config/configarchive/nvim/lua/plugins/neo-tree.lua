return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- アイコン表示に必要
		"MunifTanjim/nui.nvim",
	},
	-- lazy = false,
	event = "VeryLazy", -- Neovim起動完了後に遅延ロード
	-- lazy.nvim の 'config' 関数を使って、設定とキーマップを一緒に定義
	config = function()
		-- まずはプラグインのセットアップ
		require("neo-tree").setup({
			-- ここにneo-treeのオプションを記述
			close_if_last_window = true, -- 最後のウィンドウならNeo-treeも閉じる
			auto_clean_after_session_restore = true,
			popup_border_style = "rounded",
			enable_cursor_hijack = true, -- If enabled neotree will keep the cursor on the first letter of the filename when moving in the tree.
			window = {
				width = 30,
				-- ファイルを開くときの挙動などを設定
				mappings = {
					["<cr>"] = "open",
					["<tab>"] = "open_vsplit", -- 垂直分割で開く
					["<C-t>"] = "open_tabnew", -- 新しいタブで開く
					-- ["c"] = "add", -- ファイル/ディレクトリ追加
					-- ["C"] = "add_directory", -- ディレクトリ追加プロンプトを直接開く
					-- ["r"] = "rename", -- リネーム
					-- ["d"] = "delete", -- 削除
				},
			},
			filesystem = {
				-- gitの状態をアイコンで表示
				git_status_colors = {
					added = "282a36",
					modified = "6272a4",
					deleted = "ff5555",
					renamed = "bd93f9",
					untracked = "f1fa8c",
					ignored = "666666",
					conflicted = "ff79c6",
				},
				filtered_items = {
					visible = true,
					show_hidden_count = true,
					hide_dotfiles = false,
					hide_gitignored = true,
					hide_by_name = {
						".git",
					},
					never_show = {},
				},
				window = {
					mappings = {
						["c"] = "add", -- ファイル/ディレクトリ追加
						["C"] = "add_directory", -- ディレクトリ追加プロンプトを直接開く
						["r"] = "rename", -- リネーム
						["d"] = "delete", -- 削除
					},
				},
				-- C-c, C-v などのキーマップを有効にする
				use_libuv_file_watcher = true,
			},
			sources = {
				"filesystem",
				"document_symbols",
			},
			source_selector = {
				winbar = true,
				statusline = true,
				sources = {

					{ source = "filesystem" },
					{ source = "document_symbols" },
				},
				content_layout = "center", -- only with `tabs_layout` = "equal", "focus"
				tabs_layout = "equal", -- start, end, center, equal, focus
				truncation_character = "…", -- character to use when truncating the tab label
				tabs_min_width = nil, -- nil | int: if int padding is added based on `content_layout`
				tabs_max_width = nil, -- this will truncate text even if `text_trunc_to_fit = false`
				padding = 0, -- can be int or table
				separator = { left = "▕", right = " " },
				separator_active = nil, -- set separators around the active tab. nil falls back to `source_selector.separator`
				show_separator_on_edge = false,
				highlight_tab = "NeoTreeTabInactive",
				highlight_tab_active = "NeoTreeTabActive",
				highlight_background = "NeoTreeTabInactive",
				highlight_separator = "NeoTreeTabSeparatorInactive",
				highlight_separator_active = "NeoTreeTabSeparatorActive",
			},
			-- event_handlers = {
			-- 	-- {
			-- 	-- 	event = "file_opened",
			-- 	-- 	handler = function(file_path)
			-- 	-- 		-- auto close
			-- 	-- 		-- vimc.cmd("Neotree close")
			-- 	-- 		-- OR
			-- 	-- 		require("neo-tree.command").execute({ action = "close" })
			-- 	-- 	end,
			-- 	-- },
			-- 	{
			-- 		event = "neo_tree_buffer_enter",
			-- 		handler = function()
			-- 			-- neo-treeのウィンドウに入ったら、カーソルのハイライトをカーソル行と同じにする
			-- 			-- これにより、ブロックカーソルが背景に溶け込み、見えなくなります
			-- 			-- vim.cmd("highlight! link Cursor CursorLine")
			-- 			vim.cmd("highlight! Cursor blend = 100")
			-- 		end,
			-- 	},
			-- 	{
			-- 		event = "neo_tree_buffer_leave",
			-- 		handler = function()
			-- 			-- neo-treeから出たら、カーソルのハイライト設定のリンクを解除して元に戻す
			-- 			-- vim.cmd("highlight! link Cursor NONE")
			-- 			vim.cmd("highlight! Cursor blend = 0")
			-- 		end,
			-- 	},
			-- },
		})

		-- ここからがキーマップ設定
		local map = vim.keymap.set
		-- <leader>e でNeo-treeを開く/閉じる
		map("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
		-- <leader>b でGitの状態を表示するNeo-treeを開く
		-- map("n", "<leader>b", ":Neotree git_status<CR>", { desc = "Neo-tree git status" })
	end,
}
