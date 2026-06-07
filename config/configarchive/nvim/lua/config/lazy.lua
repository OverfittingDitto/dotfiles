-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import my plugins
		{ import = "plugins/autopairs" },
		{ import = "plugins/claudecode" },
		-- { import = "plugins/autosession" },
		{ import = "plugins/blink" },
		{ import = "plugins/bufferline" },
		{ import = "plugins/colorizer" },
		{ import = "plugins/conform" },
		-- { import = "plugins/dashboard" },
		{ import = "plugins/diffview" },
		{ import = "plugins/dropbar" },
		{ import = "plugins/eyeliner" },
		{ import = "plugins/gitgraph" },
		{ import = "plugins/gitsigns" },
		{ import = "plugins/hlchunk" },
		{ import = "plugins/lualine" },
		{ import = "plugins/luasnip" },
		{ import = "plugins/neo-tree" },
		{ import = "plugins/noice" },
		{ import = "plugins/nvim-lint" },
		{ import = "plugins/scrollbar" },
		{ import = "plugins/surround" },
		{ import = "plugins/telescope" },
		{ import = "plugins/todo-comments" },
		{ import = "plugins/toggleterm" },
		-- { import = "plugins/treesitter" },
		{ import = "plugins/which-key" },
		-- import lsp plugins
		{ import = "lsp" },
		-- NOTE: colorschemes change here
		{ import = "colorschemes/catppuccin" },
		-- { import = "colorschemes/onedark" },
		-- { import = "colorschemes/vscode" },
	},
	-- Configure any other settings here. See the documentation for more details.
	-- automatically check for plugin updates
	-- checker = { enabled = true },
	rocks = { hererocks = false },
	-- パフォーマンス設定
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"man",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"rplugin",
				"zipPlugin",
			},
		},
	},
})
