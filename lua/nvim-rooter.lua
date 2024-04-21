-- Table of module level context to be exported
local M = {}
-- Table for internal Helper context
local H = {}

H.default_config = {
	-- TODO: Need to implement more config fields
	rooter_cd_cmd = "cd",
	rooter_silent_chdir = true,
	-- rooter_resolve_links = false
	rooter_manual_only = false,
	rooter_buftypes = { "" },
	-- rooter_change_directory_for_non_project_files=''
	rooter_patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
}

M.config = vim.deepcopy(M.default_config)

H.update_config = function(config)
	vim.validate({ config = { config, "table", true } })

	config = vim.tbl_deep_extend("force", vim.deepcopy(H.default_config), config or {})

	-- TODO: Maybe good to check here that this is a table of strings:
	vim.validate({
		root_patterns = { config.root_patterns, "table", true },
		rooter_manual_only = { config.rooter_manual_only, "boolean" },
		rooter_silent_chdir = { config.rooter_silent_chdir, "boolean" },
		rooter_cd_cmd = { config.rooter_cd_cmd, "string" },
	})

	return config
end

M.setup = function(config)
	M.config = H.update_config(config)
end

H.str_in_table = function(str, tbl)
    for _, value in ipairs(tbl) do
        if value == str then
            return true
        end
    end
    return false
end

H.current_dir = function()
	return vim.fn.expand("%:p:h") -- Gets the current file's directory
end

H.dir_contains_pattern = function(dir, pattern)
	-- ZZZ: Can probably make this matching more complex using glob patterns.
	return vim.fn.glob(dir .. "/" .. pattern) ~= ""
end

H.is_root = function(dir)
	for _, root_pattern in ipairs(M.config.rooter_patterns) do
		if H.dir_contains_pattern(dir, root_pattern) then
			return true
		end
	end
	return false
end

H.parent_dir = function(dir)
	return vim.fn.fnamemodify(dir, ":h")
end

H.change_workdir = function(dir)
	if dir == vim.fn.getcwd() then
		return
	end
	vim.cmd(M.config.rooter_cd_cmd .. " " .. dir)
	if not M.config.rooter_silent_chdir then
		print("rooter " .. M.config.rooter_cd_cmd .. "  " .. dir)
	end
end

H.rooter_callback_active = function()
	if M.config.rooter_manual_only then
		return false
	end

	if not H.str_in_table(vim.bo.buftype, M.config.rooter_buftypes ) then
		return false
	end

	return true

end

H.root_callback = function()
	if not H.rooter_callback_active()  then
		return
	end
	M.root()
end

M.root = function()
	local current_dir = H.current_dir()

	root_found = false
	while not root_found do
		if H.is_root(current_dir) then
			root_found = true
		-- Got all the way to the base of the filesystem and no root dir found.
		elseif current_dir == "/" then
			break
		else
			current_dir = H.parent_dir(current_dir)
			-- What if root is never found? How do we get out of this infinite loop?
		end
	end

	if root_found then
		H.change_workdir(current_dir)
	end
end

local group = vim.api.nvim_create_augroup("NvimRooter", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "BufReadPost", "BufEnter" }, {
	group = group,
	pattern = "*", -- Applies to all files
	callback = H.root_callback,
})

-- For debugging:
-- root()

vim.api.nvim_create_user_command("Root", M.root, {})

return M
