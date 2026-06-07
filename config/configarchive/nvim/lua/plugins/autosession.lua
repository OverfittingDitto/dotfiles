return {
	"rmagatti/auto-session",
	-- lazy = false,
	event = { "VimEnter" },
	-- -enables autocomplete for opts
	-- -@module "auto-session"
	-- -@type AutoSession.Config
	opts = {
		suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
		-- log_level = 'debug',
		-- TODO: Neotree との表示をうまくできるようにする 何か行番号が消えたりした

		pre_save_cmds = { "Neotree close" },

		-- NOTE: 閉じるだけならうまく動いている 再開処理はうまくいってない

		-- post_restore_cmds = { "Neotree filesystem show" },
	},
}
