require("lze").load({
	{
		"conform.nvim",
		enabled = require("nixCatsUtils").enableForCategory("format"),
		-- cmd = { "" },
		-- event = "",
		-- ft = "",
		keys = {
			{ "<leader>cf", desc = "[c]ode [f]ormat" },
		},
		-- colorscheme = "",
		after = function(plugin)
			local conform = require("conform")

			conform.setup({
				formatters_by_ft = {
					-- NOTE: download some formatters in lspsAndRuntimeDeps
					-- and configure them here
					lua = { "stylua" },
					fish = { "fish_indent" },
					-- go = { "gofmt", "golint" },
					-- templ = { "templ" },
					-- Conform will run multiple formatters sequentially
					python = { "isort", "black" },
					toml = { "taplo" },
					-- Use a sub-list to run only the first available formatter
					-- javascript = { { "prettierd", "prettier" } },
				},
				format_on_save = function(bufnr)
					-- Disable autoformat on certain filetypes
					local ignore_filetypes = { "sql", "java" }
					if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
						return
					end
					-- Disable with a global or buffer-local variable
					if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
						return
					end
					-- Disable autoformat for files in a certain path
					local bufname = vim.api.nvim_buf_get_name(bufnr)
					if bufname:match("/node_modules/") then
						return
					end
					-- ...additional logic...
					return { timeout_ms = 500, lsp_format = "fallback" }
				end,
			})

			vim.keymap.set({ "n", "v" }, "<leader>cf", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "[c]ode [f]ormat" })
		end,
	},
})
