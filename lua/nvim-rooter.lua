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

M.setup = function(config) end

local current_dir = function()
	return vim.fn.expand("%:p:h") -- Gets the current file's directory
end

local dir_contains_pattern = function(dir, filename)
	-- ZZZ: Can probably make this matching more complex using glob patterns.
	return vim.fn.glob(dir .. "/" .. filename) ~= ""
end

local is_root = function(dir)
	for _, root_pattern in ipairs(M.config.rooter_patterns) do
		if dir_contains_pattern(dir, root_pattern) then
			return true
		end
	end
	return false
end

local parent_dir = function(dir)
	return vim.fn.fnamemodify(dir, ":h")
end

local change_workdir = function(dir)
	if dir == vim.fn.getcwd() then
		return
	end
	vim.api.nvim_set_current_dir(dir)
end

local root = function()
	local current_dir = current_dir()

	root_found = false
	while not root_found do
		if is_root(current_dir) then
			root_found = true
		elseif current_dir == "/" then
			break
		else
			current_dir = parent_dir(current_dir)
			-- What if root is never found? How do we get out of this infinite loop?
		end
	end

	if root_found then
		change_workdir(current_dir)
	end
end

local group = vim.api.nvim_create_augroup("NvimRooter", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "BufReadPost", "BufEnter" }, {
	group = group,
	pattern = "*", -- Applies to all files
	callback = root,
})

-- For debugging:
-- root()

return M
