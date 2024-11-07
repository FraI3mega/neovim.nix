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
          fish = {"fish_indent"},
          -- go = { "gofmt", "golint" },
          -- templ = { "templ" },
          -- Conform will run multiple formatters sequentially
          python = { "isort", "black" },
          -- Use a sub-list to run only the first available formatter
          -- javascript = { { "prettierd", "prettier" } },
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>F", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "[F]ormat File" })
    end,
  },
})
