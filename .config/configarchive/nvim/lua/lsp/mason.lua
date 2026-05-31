return {
	-- 1. Mason本体
	-- 役割: LSPサーバー、リンター、フォーマッターなどをインストール・管理する
	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		opts = {
			ui = {
				border = "rounded",
			},
		},
	},

	-- 2. Masonとlspconfigを連携させるためのヘルパープラグイン
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
		},
		event = "VeryLazy",
		opts = {
			-- 自動インストールするLSPサーバー一覧
			-- rust_analyzer / pyright は mise 管理のため除外
			ensure_installed = {
				"lua_ls",
				"cssls",
				"html",
				"jsonls",
				"marksman",
				"taplo",
				"ts_ls",
			},
		},
	},
}
