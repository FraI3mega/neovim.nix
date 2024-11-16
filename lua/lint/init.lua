require("lze").load({
  {
    "none-ls.nvim",
    -- cmd = { "" },
    event = "FileType",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.code_actions.statix,
          null_ls.builtins.diagnostics.actionlint,
          null_ls.builtins.diagnostics.fish,
          null_ls.builtins.diagnostics.markdownlint_cli2,
        },
      })
    end,
  },
})
