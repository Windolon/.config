-- marco pierre white does not mind his lamb chops being well done.
-- i dont mind my config having plugins.
--
-- i want things to look good, be easy to configure and to maintain, and
-- be unobtrusive and show up only when i mean them to.
-- each plugin and option has their place here.

-- {{{ general options, :h 'optionname'
-- sir, the npm pack- NO.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- feel good options.
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 30
vim.opt.showmode = false -- statusline takes care of this
vim.opt.breakindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.confirm = true
vim.opt.winborder = "rounded"
vim.lsp.inlay_hint.enable(true)
vim.opt.updatetime = 250

-- :h spell
vim.opt.spelllang = { "en", "de" }

-- im just used to this search behaviour, shrug
vim.opt.ignorecase = true
vim.opt.smartcase = true -- \Cquery to force case-sensitive search regardless

-- needed for a bunch of plugins, also gives padding to the left which looks nice
vim.opt.signcolumn = "yes"

-- persistent undos
vim.opt.undofile = true

-- sync os' and nvim's clipboard
-- schedule this to reduce startup time impact
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- guess-indent probably takes care of this but its still good to have some defaults (wtf is with 8?)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.expandtab = true

vim.opt.pumheight = 10

vim.g.netrw_banner = 0

-- recommended by auto-session
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

vim.diagnostic.config({
	signs = {
		text = {
			-- yes.
			[vim.diagnostic.severity.ERROR] = "■ ",
			[vim.diagnostic.severity.WARN] = "■ ",
			[vim.diagnostic.severity.INFO] = "■ ",
			[vim.diagnostic.severity.HINT] = "■ ",
		},
	},
	-- underline is true by default
	virtual_text = true,
})
-- }}}

-- {{{ native keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = "ü"

-- :h index to see default mappings

vim.keymap.set("n", "<leader>ni", "<Cmd>e $MYVIMRC<CR>", { desc = "Edit init.lua" })
vim.keymap.set("n", "<leader>nr", "<Cmd>restart<CR>", { desc = ":restart" })
vim.keymap.set("n", "<leader>nu", vim.pack.update, { desc = "Update all plugins" })

vim.keymap.set("n", "<Esc>", "<Cmd>noh<CR>", { desc = "Turn off highlighting until the next search" })

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Return to Nt mode" })

-- <C-Left> and <C-Right> are aliases for B and W originally (i dont use them)
vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- default keymaps with improved behaviour
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })
-- }}}

-- {{{ essential plugins
-- {{{ kanagawa.nvim:                        colour theme
vim.pack.add({
	{ src = "https://github.com/rebelot/kanagawa.nvim" },
})
require("kanagawa").setup({
	-- Remove the background of LineNr, {Sign,Fold}Column and friends
	colors = {
		theme = {
			all = {
				ui = {
					bg_gutter = "none",
				},
			},
		},
	},
	-- More uniform colors for the popup menu
	overrides = function(colors)
		local theme = colors.theme
		return {
			Pmenu = { fg = theme.ui.fg, bg = theme.ui.float.bg }, -- add `blend = vim.o.pumblend` to enable transparency
			PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
			PmenuSbar = { bg = theme.ui.bg_m1 },
			PmenuThumb = { bg = theme.ui.special },
			PmenuKind = { bg = theme.ui.float.bg },
			PmenuKindSel = { fg = "NONE", bg = theme.ui.bg_p2 },
			PmenuExtra = { bg = theme.ui.float.bg },
			PmenuExtraSel = { fg = "NONE", bg = theme.ui.bg_p2 },
			BlinkCmpMenuBorder = { fg = theme.ui.float.fg_border, bg = "" }, -- why isnt this linked to Pmenu hlgroups
		}
	end,
})
vim.cmd.colorscheme("kanagawa-dragon")
-- }}}
-- {{{ heirline.nvim:                        statusline framework
require("plugins.heirline")
-- }}}
-- {{{ mini.nvim:                            library of improvement plugins
-- woah, are you just downloading a bunch of shit 80% of which you dont use??
-- "i dont mind my lamb chops being well done."
vim.pack.add({
	{ src = "https://github.com/nvim-mini/mini.nvim" },
})

-- icon provider
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

-- file explorer
-- this is awesome. i cant live without this.
require("mini.files").setup()
vim.keymap.set("n", "<leader>e", MiniFiles.open, { desc = "Open mini.files explorer" })

-- extend and create [a]round/[i]nside textobjects
-- have been using this plugin's features without even realising.
require("mini.ai").setup()

-- surround actions
-- same with mini.ai: been using the features for granted.
require("mini.surround").setup()

-- snippets engine
-- also provides extensibility, such as custom snippets. need that.
local gen_loader = require("mini.snippets").gen_loader
require("mini.snippets").setup({
	snippets = {
		-- Load custom file with global snippets first (adjust for Windows)
		gen_loader.from_file("~/.config/nvim/snippets/global.json"),

		-- Load snippets based on current language by reading files from
		-- "snippets/" subdirectories from 'runtimepath' directories.
		gen_loader.from_lang(),
	},
})

-- notifications
-- turns out its good to know what is happening around you.
require("mini.notify").setup()

-- move selections around
require("mini.move").setup()

-- highlights word under cursor
require("mini.cursorword").setup()

-- indent guide
require("mini.indentscope").setup({
	symbol = "│",
})
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		if ft == "help" then
			vim.b[args.buf].miniindentscope_disable = true
		end
	end,
})

-- trailing space guides
require("mini.trailspace").setup()
-- }}}
-- {{{ fzf-lua:                              fuzzy finder
-- this is very powerful.
vim.pack.add({
	{ src = "https://github.com/ibhagwan/fzf-lua" },
})
require("fzf-lua").setup()
vim.keymap.set("n", "<leader>ff", '<Cmd>lua require("fzf-lua").files()<CR>', { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>fg", '<Cmd>lua require("fzf-lua").live_grep()<CR>', { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", '<Cmd>lua require("fzf-lua").buffers()<CR>', { desc = "Fuzzy find open buffers" })
vim.keymap.set("n", "<leader>fh", '<Cmd>lua require("fzf-lua").help_tags()<CR>', { desc = "Fuzzy find help tags" })
-- }}}
-- {{{ guess-indent.nvim:                    indentation styles inferred from individual buffers
vim.pack.add({
	{ src = "https://github.com/NMAC427/guess-indent.nvim" },
})
require("guess-indent").setup({})
-- }}}
-- {{{ nvim-ufo <- promise-async:            better folding behaviours
-- i am a folder. you heard it here first. i need nvim-ufo.
-- also, nvim-ufo makes folds prettier and more... minimalistic.
vim.pack.add({
	{ src = "https://github.com/kevinhwang91/promise-async" },
	{ src = "https://github.com/kevinhwang91/nvim-ufo" },
})
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:"
vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
require("ufo").setup()
-- }}}
-- {{{ gitsigns.nvim:                        git integration
vim.pack.add({
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
})
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "Next hunk" })

		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "Previous hunk" })

		-- Actions
		map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage hunk" })
		map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset hunk" })

		map("v", "<leader>gs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Stage hunk" })

		map("v", "<leader>gr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Reset hunk" })

		map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Stage buffer" })
		map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Reset buffer" })
	end,
})
-- }}}
-- {{{ auto-session:                         automated session manager
vim.pack.add({
	{ src = "https://github.com/rmagatti/auto-session" },
})
require("auto-session").setup({
	suppressed_dirs = { "~/", "~/Downloads/", "/" },
})
-- }}}
-- {{{ blink.cmp:                            autocompletion
vim.pack.add({
	{
		src = "https://github.com/saghen/blink.cmp",
		version = "v1.8.0", -- pin to a release to download prebuilt bins
	},
})
require("blink.cmp").setup({
	keymap = {
		preset = "default",
		-- remaps C-space to C-d because tmux's prefix is C-space
		["<C-space>"] = false,
		["<C-d>"] = { "show", "show_documentation", "hide_documentation" },
		-- no more "i am using the arrow keys to navigate in insert mode can you please stop interrupting"
		["<Up>"] = false,
		["<Down>"] = false,
	},
	appearance = { nerd_font_variant = "normal" },
	completion = { documentation = { auto_show = false } },
	snippets = { preset = "mini_snippets" },
	sources = {
		default = { "lsp", "path", "snippets", "buffer", "omni" },
	},
	fuzzy = { implementation = "prefer_rust_with_warning" },
})
-- }}}
-- {{{ tabout.nvim:                          tabout from pairs
vim.pack.add({
	{ src = "https://github.com/abecodes/tabout.nvim" },
})
require("tabout").setup({
	tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
	backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
	act_as_tab = true, -- shift content if tab out is not possible
	act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
	default_tab = "<C-t>", -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
	default_shift_tab = "<C-d>", -- reverse shift default action,
	enable_backwards = true, -- well ...
	completion = true, -- if the tabkey is used in a completion pum
	tabouts = {
		{ open = "'", close = "'" },
		{ open = '"', close = '"' },
		{ open = "`", close = "`" },
		{ open = "(", close = ")" },
		{ open = "[", close = "]" },
		{ open = "{", close = "}" },
		{ open = "<", close = ">" },
		{ open = ",", close = "," },
		{ open = ";", close = ";" },
		{ open = "=", close = "=" },
	},
	ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
	exclude = {}, -- tabout will ignore these filetypes
})
-- }}}
-- }}}

-- {{{ treesitter
-- ok yes, you can download and setup treesitters natively, but i've tried it and
-- its a huge pain in the ass.
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})
-- i dont mind my lamb chops well done.
require("nvim-treesitter").install({ "all" })
-- automatically start treesitter if the filetype is supported
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		-- there is still a chance that this will error so we wrap it in a pcall
		pcall(vim.treesitter.start)
	end,
})
-- }}}

-- {{{ mason.nvim & mason-tool-installer.nvim
vim.pack.add({
	-- package manager for LSPs, DAPs, linters and formatters
	-- mason might truly be necessary, because its just painless.
	-- i tried setting up lua_ls manually but its a complete mess, see below.
	{ src = "https://github.com/mason-org/mason.nvim" },
	-- automatic installer for mason.nvim, for even better portability.
	-- why isnt this default mason behaviour?
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
})
require("mason").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		-- exceptions:
		--   pyright and black: per-venv basis
		--   rust-analyzer: via rustup
		"lua-language-server", -- only the mason build works, WTF?
		"stylua",
	},
})
-- }}}

-- {{{ LSP
vim.lsp.enable({
	"lua_ls",
	"rust_analyzer",
})
-- }}}

-- {{{ format on write (conform.nvim)
-- trust me, i wouldve implemented this behaviour natively if it didnt suck.
-- on the other hand, conform just works with minimal config lines.
vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim" },
})
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
	},
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 500,
	},
})
-- }}}

-- vim: foldmethod=marker foldlevel=0
