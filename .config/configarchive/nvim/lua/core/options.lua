-- /nvim/lua/core/options.lua
-- Neovimの基本オプション設定

-- [[ グローバル設定 ]]
-- Neovim起動時に即時設定しても安全なオプション

-- 表示言語 (EN/JP) を切り替える場合は、以下の行をコメントアウト/解除してください
-- vim.cmd("language en_US.UTF-8") -- 表示言語を英語にする
vim.cmd("language ja_JP.UTF-8") -- 表示言語を日本語にする

-- vim.opt.fileencoding = "utf-8" -- Neovim デフォルトが UTF-8 のため不要 (0.12+ で非modifiableバッファにセット不可)
vim.opt.swapfile = false -- スワップファイルを作成しない
vim.opt.hidden = true -- 保存せずにバッファを切り替え可能にする
vim.opt.autoread = true -- 外部でファイルが変更されたとき自動リロード

-- tmux pane を切り替えたときに外部変更を検知してリロード
-- (tmux.conf の focus-events on と組み合わせて動作)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})
vim.opt.termguicolors = true -- ターミナルで24-bit True Colorを有効にする
-- NOTE: 透明化関係
vim.opt.winblend = 0
vim.opt.pumblend = 0

vim.opt.background = "dark" -- 背景色を'dark' or 'light'に設定 (多くのカラースキームが自動で設定)
vim.opt.laststatus = 3 -- ステータスラインの表示設定 (3: 常にグローバル表示)
vim.opt.cmdheight = 1 -- コマンドラインの高さを1行に設定
vim.opt.wildmenu = true -- コマンドライン補完を有効化
vim.opt.hlsearch = true -- 検索結果をハイライト
vim.opt.incsearch = true -- 入力中に検索結果をリアルタイム表示
vim.opt.ignorecase = true -- 検索時に大文字と小文字を区別しない
vim.opt.smartcase = true -- 検索語に大文字が含まれている場合は区別する
vim.opt.clipboard = "unnamedplus" -- OSのクリップボードとヤンクレジスタを共有
vim.opt.mouse = "a" -- すべてのモードでマウスを有効にする
vim.o.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20" -- カーソルの形状をモードごとに設定

-- lazy.nvimなどのUIとの干渉を避けるため、VimEnterイベント(起動完了後)で設定します
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("MyOptions", { clear = true }),
	pattern = "*",
	callback = function()
		local opt = vim.opt

		-- カーソルと表示
		opt.cursorline = true -- カーソル行をハイライト

		-- インデント
		opt.shiftwidth = 4 -- 自動インデントや<>で使うインデント幅
		opt.tabstop = 4 -- タブ文字の表示幅
		opt.expandtab = true -- Tabキーでタブ文字の代わりにスペースを挿入
		opt.autoindent = true -- 改行時に前の行のインデントを引き継ぐ (smartindentはtreesitterに任せるため無効)

		-- 表示
		opt.number = true -- 行番号を表示
		opt.relativenumber = true   -- カーソル行からの相対行番号を表示
		opt.wrap = true -- 長い行の折り返し表示を有効化・無効化
		opt.showtabline = 2 -- タブバーの表示設定 (2: タブが2つ以上ある時に表示)
		opt.visualbell = true -- エラー音の代わりに画面をフラッシュ
		opt.showmatch = true -- 対応する括弧を短時間ハイライト
		opt.matchtime = 1 -- 括弧ハイライトの表示時間 (1/10秒単位)
		opt.signcolumn = "yes" -- LSPの診断やGitの差分アイコン用の列を常に表示

		-- インタフェース
		opt.winblend = 0 -- フローティングウィンドウの透過度 (0: 不透明)
		opt.pumblend = 0 -- ポップアップメニューの透過度 (0: 不透明)
		opt.virtualedit = "block" -- 行末より後ろにもカーソルを移動できるようにする (block: ビジュアルブロックモード時)
		-- Diagnostic Config
		-- See :help vim.diagnostic.Opts
		vim.diagnostic.config({
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			underline = { severity = vim.diagnostic.severity.ERROR },
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			} or {},
			virtual_text = {
				source = "if_many",
				spacing = 2,
				format = function(diagnostic)
					local diagnostic_message = {
						[vim.diagnostic.severity.ERROR] = diagnostic.message,
						[vim.diagnostic.severity.WARN] = diagnostic.message,
						[vim.diagnostic.severity.INFO] = diagnostic.message,
						[vim.diagnostic.severity.HINT] = diagnostic.message,
					}
					return diagnostic_message[diagnostic.severity]
				end,
			},
		})
	end,
})
