local colorschemeName = nixCats("colorscheme")
return {
	{
		"lualine.nvim",
		-- cmd = { "" },
		event = "DeferredUIEnter",
		-- ft = "",
		-- keys = "",
		-- colorscheme = "",
		after = function(plugin)
			require("lualine").setup({
				options = {
					theme = "catppuccin",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				extensions = { "nvim-dap-ui", "oil", "quickfix", "trouble", "aerial", "toggleterm" },
				globalstatus = true,
				sections = {
					lualine_c = {
						{
							"filename",
							path = 1,
							status = true,
						},
					},

					lualine_x = {
						"searchcount",
						"filetype",
					},
				},
				inactive_sections = {
					lualine_b = {
						{
							"filename",
							path = 3,
							status = true,
						},
					},
					lualine_c = { "filesize" },
					lualine_x = { "filetype" },
				},
			})
		end,
	},
	{
		"barbar.nvim",
		event = "DeferredUIEnter",
		after = function(plugin)
			local map = vim.keymap.set
			local buffer = "<leader><leader>"
			map("n", "[b", "<Cmd>BufferPrevious<CR>", { desc = "Switch to previous buffer" })
			map("n", "]b", "<Cmd>BufferNext<CR>", { desc = "Switch to next buffer" })
			map("n", buffer .. "P", "<Cmd>BufferPin<CR>", { desc = "[P]in current buffer" })
			map("n", buffer .. "p", "<Cmd>BufferPick<CR>", { desc = "[p]ick buffer" })
			-- Sort automatically by...
			map("n", buffer .. "sb", "<Cmd>BufferOrderByBufferNumber<CR>", { desc = "Sort by buffer number" })
			map("n", buffer .. "sn", "<Cmd>BufferOrderByName<CR>", { desc = "Sort by [n]ame" })
			map("n", buffer .. "sd", "<Cmd>BufferOrderByDirectory<CR>", { desc = "Sort by [d]irectory" })
			map("n", buffer .. "sl", "<Cmd>BufferOrderByLanguage<CR>", { desc = "Sort by [l]anguage" })
			map("n", buffer .. "sw", "<Cmd>BufferOrderByWindowNumber<CR>", { desc = "Sort by [w]indow number" })

			map("n", buffer .. "c", "<Cmd>BufferClose<CR>", { desc = "[c]lose buffer" }) -- close
		end,
	},
	{
		"barbecue.nvim",
		event = "DeferredUIEnter",
		after = function(plugin)
			require("barbecue").setup({
				theme = "catppuccin-mocha",
			})
		end,
	},
}
