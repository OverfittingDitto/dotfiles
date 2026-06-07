return {
	vim.lsp.config("ts_ls", {
		settings = {
			typescript = {
				inlayHints = {
					includeInlayParameterNameHints = "literals",
					includeInlayFunctionLikeReturnTypeHints = true,
				},
			},
			javascript = {
				inlayHints = {
					includeInlayParameterNameHints = "literals",
					includeInlayFunctionLikeReturnTypeHints = true,
				},
			},
		},
	}),
}
