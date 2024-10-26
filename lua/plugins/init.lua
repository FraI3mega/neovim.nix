require("plugins.colorscheme")
-- NOTE: you can check if you included the category with the thing wherever you want.
if nixCats("general.extra") then
	-- I didnt want to bother with lazy loading this.
	-- I could put it in opt and put it in a spec anyway
	-- and then not set any handlers and it would load at startup,
	-- but why... I guess I could make it load
	-- after the other lze definitions in the next call using priority value?
	-- didnt seem necessary.

	vim.g.loaded_netrwPlugin = 1
	require("oil").setup({
		default_file_explorer = true,
		columns = {
			"icon",
			"permissions",
			"size",
			-- "mtime",
		},
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<C-s>"] = "actions.select_vsplit",
			["<C-h>"] = "actions.select_split",
			["<C-t>"] = "actions.select_tab",
			["<C-p>"] = "actions.preview",
			["<C-c>"] = "actions.close",
			["<C-l>"] = "actions.refresh",
			["-"] = "actions.parent",
			["_"] = "actions.open_cwd",
			["`"] = "actions.cd",
			["~"] = "actions.tcd",
			["gs"] = "actions.change_sort",
			["gx"] = "actions.open_external",
			["g."] = "actions.toggle_hidden",
			["g\\"] = "actions.toggle_trash",
		},
	})
	vim.keymap.set("n", "-", "<cmd>Oil<CR>", { noremap = true, desc = "Open Parent Directory" })
	vim.keymap.set("n", "<leader>-", "<cmd>Oil .<CR>", { noremap = true, desc = "Open nvim root directory" })

	local smart_splits = require("smart-splits")
	smart_splits.setup({
		ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
		ignored_buftypes = { "nofile" },
	})

	vim.keymap.set("n", "<C-H>", function()
		smart_splits.move_cursor_left()
	end, { desc = "Move to right split" })
	vim.keymap.set("n", "<C-J>", function()
		smart_splits.move_cursor_down()
	end, { desc = "Move to below split" })
	vim.keymap.set("n", "<C-K>", function()
		smart_splits.move_cursor_up()
	end, { desc = "Move to above split" })
	vim.keymap.set("n", "<C-L>", function()
		smart_splits.move_cursor_right()
	end, { desc = "Move to left split" })
	vim.keymap.set("n", "<A-h>", function()
		smart_splits.resize_left()
	end, { desc = "Resize right split" })
	vim.keymap.set("n", "<A-j>", function()
		smart_splits.resize_down()
	end, { desc = "Resize below split" })
	vim.keymap.set("n", "<A-k>", function()
		smart_splits.resize_up()
	end, { desc = "Resize above split" })
	vim.keymap.set("n", "<A-l>", function()
		smart_splits.resize_right()
	end, { desc = "Resize left split" })

	require("persisted").branch = function()
		local branch = vim.fn.systemlist("git branch --show-current")[1]
		return vim.v.shell_error == 0 and branch or nil
	end

	require("persisted").setup({
		use_git_branch = true, -- Include the git branch in the session file name?
		autoload = true,     -- Automatically load the session for the cwd on Neovim startup?
	})

	vim.opt.sessionoptions:append("globals")
	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "PersistedSavePre",
		group = vim.api.nvim_create_augroup("PersistedHooks", {}),
		callback = function()
			vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })
		end,
	})
end

require("lze").load({
	{ import = "plugins.telescope" },
	{ import = "plugins.treesitter" },
	{ import = "plugins.completion" },
	{ import = "plugins.lines" },
	{ import = "plugins.language-specific" },
	{ import = "plugins.neotest" },
	{
		"lazydev.nvim",
		cmd = { "LazyDev" },
		ft = "lua",
		after = function(plugin)
			require("lazydev").setup({
				library = {
					{ words = { "nixCats" }, path = (require("nixCats").nixCatsPath or "") .. "/lua" },
				},
			})
		end,
	},
	{
		"markdown-preview.nvim",
		cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
		ft = "markdown",
		keys = {
			{
				"<leader>mp",
				"<cmd>MarkdownPreview <CR>",
				mode = { "n" },
				noremap = true,
				desc = "markdown preview",
			},
			{
				"<leader>ms",
				"<cmd>MarkdownPreviewStop <CR>",
				mode = { "n" },
				noremap = true,
				desc = "markdown preview stop",
			},
			{
				"<leader>mt",
				"<cmd>MarkdownPreviewToggle <CR>",
				mode = { "n" },
				noremap = true,
				desc = "markdown preview toggle",
			},
		},
		before = function(plugin)
			vim.g.mkdp_auto_close = 0
		end,
	},
	{
		"undotree",
		cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo" },
		keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" } },
		before = function(_)
			vim.g.undotree_WindowLayout = 1
			vim.g.undotree_SplitWidth = 40
		end,
	},
	{
		"comment.nvim",
		event = "DeferredUIEnter",
		after = function(plugin)
			require("Comment").setup()
		end,
	},
	{
		"nvim-navic",
		dep_of = "barbecue.nvim",
		after = function(plugin)
			require("nvim-navic").setup({
				lsp = { auto_attach = true },
			})
		end,
	},
	{
		"indent-blankline.nvim",
		event = "DeferredUIEnter",
		after = function(plugin)
			require("ibl").setup()
		end,
	},
	{
		"nvim-surround",
		event = "DeferredUIEnter",
		-- keys = "",
		after = function(plugin)
			require("nvim-surround").setup()
		end,
	},
	{
		"vim-startuptime",
		cmd = { "StartupTime" },
		before = function(_)
			vim.g.startuptime_event_width = 0
			vim.g.startuptime_tries = 10
			vim.g.startuptime_exe_path = require("nixCatsUtils").packageBinPath
		end,
	},
	{
		"auto-save",
		event = { "InsertLeave", "TextChanged" },
		cmd = "ASToggle",
		after = function(plugin)
			require("auto-save").setup({
				condition = function(buf)
					local fn = vim.fn
					local utils = require("auto-save.utils.data")

					-- don't save for `sql` file types
					if utils.not_in(fn.getbufvar(buf, "&filetype"), { "oil" }) then
						return true
					end
					return false
				end,
			})
		end,
	},
	{
		"aerial.nvim",
		cmd = { "AerialToggle", "AerialNavToggle" },
		keys = {
			{ "<leader>wS", "<cmd>AerialToggle<cr>", mode = "n", desc = "[S]ymbols outline" },
		},
		after = function(plugin)
			require("aerial").setup({ show_guides = true })
		end,
	},
	{
		"dial.nvim",
		-- lazy-load on keys. -- Mode is `n` by default.
		keys = { "<C-a>", { "<C-x>", mode = "n" } },
	},
	{
		"fidget.nvim",
		event = "DeferredUIEnter",
		-- keys = "",
		after = function(plugin)
			require("fidget").setup({})
		end,
	},
	{
		"gitsigns.nvim",
		event = "DeferredUIEnter",
		-- cmd = { "" },
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		after = function(plugin)
			require("gitsigns").setup({
				-- See `:help gitsigns.txt`
				signs = {
					add = { text = "+" },
					change = { text = "~" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map({ "n", "v" }, "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Jump to next hunk" })

					map({ "n", "v" }, "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Jump to previous hunk" })

					-- Actions
					-- visual mode
					map("v", "<leader>hs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "stage git hunk" })
					map("v", "<leader>hr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "reset git hunk" })
					-- normal mode
					map("n", "<leader>gs", gs.stage_hunk, { desc = "git stage hunk" })
					map("n", "<leader>gr", gs.reset_hunk, { desc = "git reset hunk" })
					map("n", "<leader>gS", gs.stage_buffer, { desc = "git Stage buffer" })
					map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
					map("n", "<leader>gR", gs.reset_buffer, { desc = "git Reset buffer" })
					map("n", "<leader>gp", gs.preview_hunk, { desc = "preview git hunk" })
					map("n", "<leader>gb", function()
						gs.blame_line({ full = false })
					end, { desc = "git blame line" })
					map("n", "<leader>gd", gs.diffthis, { desc = "git diff against index" })
					map("n", "<leader>gD", function()
						gs.diffthis("~")
					end, { desc = "git diff against last commit" })

					-- Toggles
					map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
					map("n", "<leader>gtd", gs.toggle_deleted, { desc = "toggle git show deleted" })

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
				end,
			})
			vim.cmd([[hi GitSignsAdd guifg=#04de21]])
			vim.cmd([[hi GitSignsChange guifg=#83fce6]])
			vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
		end,
	},
	{
		"which-key.nvim",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		after = function(plugin)
			require("which-key").setup({})
			require("which-key").add({
				{ "<leader>b",   group = "[b]uffer" },
				{ "<leader>b_",  hidden = true },
				{ "<leader>bs",  group = "[s]ort" },
				{ "<leader>bs_", hidden = true },
				{ "<leader>c",   group = "[c]ode" },
				{ "<leader>c_",  hidden = true },
				{ "<leader>d",   group = "[d]ocument" },
				{ "<leader>d_",  hidden = true },
				{ "<leader>g",   group = "[g]it" },
				{ "<leader>g_",  hidden = true },
				{ "<leader>m",   group = "[m]arkdown" },
				{ "<leader>m_",  hidden = true },
				{ "<leader>r",   group = "[r]ename" },
				{ "<leader>r_",  hidden = true },
				{ "<leader>s",   group = "[s]earch" },
				{ "<leader>s_",  hidden = true },
				{ "<leader>t",   group = "[t]oggles" },
				{ "<leader>t_",  hidden = true },
				{ "<leader>w",   group = "[w]orkspace" },
				{ "<leader>w_",  hidden = true },
				-- { "<leader>T",         group = "[T]ests" },
				-- { "<leader>T_",        hidden = true },
			})
		end,
	},
})
