-- My god, what are you doing? A separate config file from init.lua? Yes indeed.
--
-- custom eviline-esque statusline implemented with heirline.nvim, because
-- lets be honest, do we need all that lualine framework if we are just
-- going to reimplement eviline from the ground up? why not just use an actual
-- framework like heirline?
--
-- yes yes, i know the code is a mess. maintainability, blah blah blah.
-- if it works it works. plus config files like this are basically just
-- a set-and-forget type of deal.
--
-- i also thought of implementing this purely natively, but cba.

vim.pack.add({
	{ src = "https://github.com/rebelot/heirline.nvim" },
})

local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

-- highlight groups can be retrieved from, usually, the highlights/ directory.
local colors = {
	-- terminal colours taken from kanagawa-dragon
	red = "#c4746e",
	green = "#8a9a7b",
	yellow = "#c4b28a",
	blue = "#8ba4b0",
	magenta = "#a292a3",
	cyan = "#8ea4a2",
	white = "#c8c093",
	brblack = "#a6a69c",
	orange = "#b6927b",

	directory = utils.get_highlight("Directory").fg,
	inactive = utils.get_highlight("NonText").fg,
	comment = utils.get_highlight("Comment").fg,
	parameter = utils.get_highlight("@variable.parameter").fg,
	type = utils.get_highlight("Type").fg,
	diag_error = utils.get_highlight("DiagnosticError").fg,
	diag_warn = utils.get_highlight("DiagnosticWarn").fg,
	diag_info = utils.get_highlight("DiagnosticInfo").fg,
	diag_hint = utils.get_highlight("DiagnosticHint").fg,
	git_add = utils.get_highlight("diffAdded").fg,
	git_del = utils.get_highlight("diffDeleted").fg,
	git_change = utils.get_highlight("diffChanged").fg,
}
require("heirline").load_colors(colors)

-- {{{ LeftEnd
local LeftEnd = {
	provider = "█  ",
}
-- }}}
-- {{{ RightEnd
local RightEnd = {
	provider = "  █",
}
-- }}}

-- {{{ ViMode
local ViMode = {
	-- get vim current mode, this information will be required by the provider
	-- and the highlight functions, so we compute it only once per component
	-- evaluation and store it as a component attribute
	init = function(self)
		self.mode = vim.fn.mode(1) -- :h mode()
	end,
	-- Now we define some dictionaries to map the output of mode() to the
	-- corresponding string and color. We can put these into `static` to compute
	-- them at initialisation time.
	static = {
		mode_names = { -- change the strings if you like it vvvvverbose!
			n = "N",
			no = "N?",
			nov = "N?",
			noV = "N?",
			["no\22"] = "N?",
			niI = "Ni",
			niR = "Nr",
			niV = "Nv",
			nt = "Nt",
			v = "V",
			vs = "Vs",
			V = "V_",
			Vs = "Vs",
			["\22"] = "^V",
			["\22s"] = "^V",
			s = "S",
			S = "S_",
			["\19"] = "^S",
			i = "I",
			ic = "Ic",
			ix = "Ix",
			R = "R",
			Rc = "Rc",
			Rx = "Rx",
			Rv = "Rv",
			Rvc = "Rv",
			Rvx = "Rv",
			c = "C",
			cv = "Ex",
			r = "..",
			rm = "M",
			["r?"] = "?",
			["!"] = "!",
			t = "T",
		},
		mode_colors = {
			n = "red",
			i = "green",
			v = "yellow",
			V = "yellow",
			["\22"] = "yellow",
			c = "orange",
			s = "magenta",
			S = "magenta",
			["\19"] = "magenta",
			R = "blue",
			r = "blue",
			["!"] = "red",
			t = "red",
		},
	},
	-- We can now access the value of mode() that, by now, would have been
	-- computed by `init()` and use it to index our strings dictionary.
	-- note how `static` fields become just regular attributes once the
	-- component is instantiated.
	-- To be extra meticulous, we can also add some vim statusline syntax to
	-- control the padding and make sure our string is always at least 2
	-- characters long. (No more icon...)
	provider = function(self)
		return "%-2(" .. self.mode_names[self.mode] .. "%)"
	end,
	-- Same goes for the highlight. Now the foreground will change according to the current mode.
	hl = function(self)
		local mode = self.mode:sub(1, 1) -- get only the first mode character
		return { fg = self.mode_colors[mode], bold = true }
	end,
	-- Re-evaluate the component only on ModeChanged event!
	-- Also allows the statusline to be re-evaluated when entering operator-pending mode
	update = {
		"ModeChanged",
		pattern = "*:*",
		callback = vim.schedule_wrap(function()
			vim.cmd("redrawstatus")
		end),
	},
}
-- }}}
-- {{{ (FileNameBlock), WorkDir, FileName, FileFlags, FileNameModifier
local FileNameBlock = {
	-- let's first set up some attributes needed by this component and its children
	init = function(self)
		self.filename = vim.api.nvim_buf_get_name(0)
	end,
}
-- We can now define some children separately and add them later

local WorkDir = {
	init = function(self)
		self.icon = (vim.fn.haslocaldir(0) == 1 and "l" or "g") .. " "
		local cwd = vim.fn.getcwd(0)
		self.cwd = vim.fn.fnamemodify(cwd, ":~")
	end,

	hl = function()
		if conditions.is_active() then
			return { fg = "comment" }
		else
			return ""
		end
	end,

	flexible = 1,

	{
		-- evaluates to the full-lenth path
		provider = function(self)
			local trail = self.cwd:sub(-1) == "/" and "" or "/"
			return self.icon .. self.cwd .. trail
		end,
	},
	{
		-- evaluates to the shortened path
		provider = function(self)
			local cwd = vim.fn.pathshorten(self.cwd)
			local trail = self.cwd:sub(-1) == "/" and "" or "/"
			return self.icon .. cwd .. trail
		end,
	},
	{
		-- evaluates to "", hiding the component
		provider = "",
	},
}

local FileName = {
	provider = function(self)
		-- first, trim the pattern relative to the current directory. For other
		-- options, see :h filename-modifers
		local filename = vim.fn.fnamemodify(self.filename, ":.")
		if filename == "" then
			return "[No Name]"
		end
		-- now, if the filename would occupy more than 1/4th of the available
		-- space, we trim the file path to its initials
		-- See Flexible Components section below for dynamic truncation
		if not conditions.width_percent_below(#filename, 0.25) then
			filename = vim.fn.pathshorten(filename)
		end
		return filename
	end,
	hl = function()
		if conditions.is_active() then
			return { fg = "directory" }
		else
			return ""
		end
	end,
}

local FileFlags = {
	{
		condition = function()
			return vim.bo.modified
		end,
		provider = "[+]",
		hl = function()
			if conditions.is_active() then
				return { fg = "green" }
			else
				return ""
			end
		end,
	},
	{
		condition = function()
			return not vim.bo.modifiable or vim.bo.readonly
		end,
		provider = "[-]",
		hl = function()
			if conditions.is_active() then
				return { fg = "orange" }
			else
				return ""
			end
		end,
	},
}

-- Now, let's say that we want the filename color to change if the buffer is
-- modified. Of course, we could do that directly using the FileName.hl field,
-- but we'll see how easy it is to alter existing components using a "modifier"
-- component

local FileNameModifer = {
	hl = function()
		if vim.bo.modified then
			if conditions.is_active() then
				-- use `force` because we need to override the child's hl foreground
				return { fg = "directory", bold = true, force = true }
			else
				return { fg = "", bold = true, force = true }
			end
		end
	end,
}

-- let's add the children to our FileNameBlock component
FileNameBlock = utils.insert(
	FileNameBlock,
	WorkDir,
	utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
	{ provider = " " }, -- the regular space is 2 wide
	FileFlags,
	{ provider = "%<" } -- this means that the statusline is cut here when there's not enough space
)
-- }}}
-- {{{ FileType
local FileType = {
	provider = function()
		return string.upper(vim.bo.filetype)
	end,
	hl = function()
		if conditions.is_active() then
			return { fg = "type", bold = true }
		else
			return { bold = true }
		end
	end,
}
-- }}}
-- {{{ Ruler
-- We're getting minimalist here!
local Ruler = {
	-- %l = current line number
	-- %L = number of lines in the buffer
	-- %c = column number
	-- %P = percentage through file of displayed window
	provider = "%7(%l/%-3L%):%-2c %P",
}
-- }}}
-- {{{ Diagnostics
local Diagnostics = {

	condition = conditions.has_diagnostics,

	init = function(self)
		self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
		self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
		self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
		self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
	end,

	update = { "DiagnosticChanged", "BufEnter" },

	{
		provider = function(self)
			-- 0 is just another output, we can decide to print it or not!
			return self.errors > 0 and ("■ " .. self.errors .. " ")
		end,
		hl = { fg = "diag_error" },
	},
	{
		provider = function(self)
			return self.warnings > 0 and ("■ " .. self.warnings .. " ")
		end,
		hl = { fg = "diag_warn" },
	},
	{
		provider = function(self)
			return self.info > 0 and ("■ " .. self.info .. " ")
		end,
		hl = { fg = "diag_info" },
	},
	{
		provider = function(self)
			return self.hints > 0 and ("■ " .. self.hints)
		end,
		hl = { fg = "diag_hint" },
	},
}
-- }}}
-- {{{ LSPActive
local LSPActive = {
	condition = conditions.lsp_attached,
	update = { "LspAttach", "LspDetach" },

	-- You can keep it simple,
	-- provider = " [LSP]",

	-- Or complicate things a bit and get the servers names
	provider = function()
		local names = {}
		for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
			table.insert(names, server.name)
		end
		return "  " .. table.concat(names, " ")
	end,
	hl = { fg = "green", bold = true },
}
-- }}}
-- {{{ Git
local Git = {
	condition = conditions.is_git_repo,

	init = function(self)
		self.status_dict = vim.b.gitsigns_status_dict
		self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
	end,

	hl = { fg = "brblack" },

	{ -- git branch name
		provider = function(self)
			return " " .. self.status_dict.head
		end,
		hl = { bold = true },
	},
	-- You could handle delimiters, icons and counts similar to Diagnostics
	{
		condition = function(self)
			return self.has_changes
		end,
		provider = "(",
	},
	{
		provider = function(self)
			local count = self.status_dict.added or 0
			return count > 0 and ("+" .. count)
		end,
		hl = { fg = "git_add" },
	},
	{
		provider = function(self)
			local count = self.status_dict.removed or 0
			return count > 0 and ("-" .. count)
		end,
		hl = { fg = "git_del" },
	},
	{
		provider = function(self)
			local count = self.status_dict.changed or 0
			return count > 0 and ("~" .. count)
		end,
		hl = { fg = "git_change" },
	},
	{
		condition = function(self)
			return self.has_changes
		end,
		provider = ")",
	},
}
-- }}}

-- {{{ HelpFileName
local HelpFileName = {
	condition = function()
		return vim.bo.filetype == "help"
	end,
	provider = function()
		local filename = vim.api.nvim_buf_get_name(0)
		return "  " .. vim.fn.fnamemodify(filename, ":t") -- piggyback on an already-written condition for the space
	end,
	hl = function()
		if conditions.is_active() then
			return { fg = "directory" }
		else
			return ""
		end
	end,
}
-- }}}
-- {{{ TerminalName
local TerminalName = {
	-- we could add a condition to check that buftype == 'terminal'
	-- or we could do that later
	provider = function()
		local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
		return tname
	end,
	hl = function()
		if conditions.is_active() then
			return { fg = "directory" }
		else
			return ""
		end
	end,
}
-- }}}

local Align = { provider = "%=" }
local Space = { provider = "  " }

-- stylua: ignore
local DefaultStatusline = {
	LeftEnd, ViMode, Space, FileNameBlock, Align,
	LSPActive, Space, Diagnostics, Align,
	Git, Space, Ruler, RightEnd,
}

-- stylua: ignore
local InactiveStatusline = {
	condition = conditions.is_not_active,
	LeftEnd, FileNameBlock, Align, Ruler, RightEnd,
}

-- stylua: ignore
local SpecialStatusline = {
	condition = function()
		return conditions.buffer_matches({
			buftype = { "nofile", "prompt", "help", "quickfix" },
		})
	end,

	LeftEnd, FileType, HelpFileName, { provider = " " }, FileFlags, Align, RightEnd,
}

-- stylua: ignore
local TerminalStatusline = {
	condition = function()
		return conditions.buffer_matches({ buftype = { "terminal" } })
	end,

	LeftEnd, TerminalName, Align, RightEnd,
}

local StatusLines = {

	hl = function()
		if conditions.is_active() then
			return "StatusLine"
		else
			return "StatusLineNC"
		end
	end,

	-- the first statusline with no condition, or which condition returns true is used.
	-- think of it as a switch case with breaks to stop fallthrough.
	fallthrough = false,

	SpecialStatusline,
	TerminalStatusline,
	InactiveStatusline,
	DefaultStatusline,
}

require("heirline").setup({ statusline = StatusLines })
-- we're done.

-- vim: foldmethod=marker foldlevel=0
