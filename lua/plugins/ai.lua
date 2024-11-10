return {
  {
    "codecompanion",
    event = "DeferredUIEnter",
    after = function(plugin)
      require("codecompanion").setup({
        display = {
          chat = {
            render_headers = false,
          },
        },
        strategies = {
          chat = {
            adapter = "ollama",
          },
          inline = {
            adapter = "ollama",
          },
        },
      })

      vim.api.nvim_set_keymap("n", "<m-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("v", "<m-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("n", "<leader>[t", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("v", "<leader>[t", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
  {
    "render-markdown.nvim",
    ft = "codecompanion",
    after = function()
      require("render-markdown").setup({
        file_types = { "codecompanion" },
        render_modes = true,
      })
    end,
  },
}
