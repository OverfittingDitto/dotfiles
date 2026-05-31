-- vscode only
--if vim.g.vscode then
--end

-- neovim only
if not vim.g.vscode then
	-- only Neovim
	require("config.lazy")
end

-- reqsonuire core/ and user/
require("core.options")
require("core.keymaps")
