local M = {}

M.config = {
	-- TODO: Need to implement more config fields
	-- rooter_cd_cmd = 'cd'
	-- rooter_silent_chdir = false,
	-- rooter_resolve_links = false
	-- rooter_manual_only=false
	-- rooter_change_directory_for_non_project_files=''
	rooter_patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
}

M.setup = function(config)
end
local function root()
	print("root")
end

local group = vim.api.nvim_create_augroup("NvimRooter", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "BufReadPost", "BufEnter" }, {
	group=group,
	pattern = "*", -- Applies to all files
	callback = root,
})

return M
