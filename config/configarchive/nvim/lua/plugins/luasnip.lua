-- スニペットエンジン (LuaSnip) の設定
return {
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		-- スニペットの雛形を提供するリポジトリもここで管理
		dependencies = { "rafamadriz/friendly-snippets" },
		event = { "InsertEnter", "CmdLineEnter" },
		config = function()
			-- local ls = require("luasnip")

			-- 1. VSCode形式のスニペット集(friendly-snippets)を読み込む
			require("luasnip.loaders.from_vscode").lazy_load()

			-- 2. 私たちが作成したカスタムスニペットを読み込む
			--    "all" はすべてのファイルタイプで有効にすることを意味する
			-- ls.add_snippets("all", require("custom_snippets.snippets"))
			require("luasnip.loaders.from_lua").load({ paths = { "~/.config/nvim/lua/luasnippets" } })
		end,
	},
}
