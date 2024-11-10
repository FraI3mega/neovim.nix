return {
  -- Rust
  {
    "crates.nvim",
    event = { "BufRead Cargo.toml" },
    after = function()
      require("crates").setup({
        completion = {
          crates = { enabled = true },
        },
        popup = {
          autofocus = true,
        },
        lsp = {
          enabled = true,
          on_attach = function(client, bufnr)
            local prefix = "<leader>cC"
            local crates = require("crates")
            local map = vim.keymap.set

            map("n", prefix, function() end, { desc = "Crates.nvim", buffer = bufnr })
            map("n", prefix .. "u", function() crates.update_crate() end, { desc = "Update crate", buffer = bufnr })
            map(
              "n",
              prefix .. "a",
              function() crates.update_all_crates() end,
              { desc = "Update all crates", buffer = bufnr }
            )
            map("n", prefix .. "U", function() crates.upgrade_crate() end, { desc = "Upgrade crate", buffer = bufnr })
            map(
              "n",
              prefix .. "A",
              function() crates.upgrade_all_crates() end,
              { desc = "Upgrade all crates", buffer = bufnr }
            )
            map(
              "n",
              prefix .. "x",
              function() crates.expand_plain_crate_to_inline_table() end,
              { desc = "Expand into inline table", buffer = bufnr }
            )
            map(
              "n",
              prefix .. "X",
              function() crates.extract_crate_into_table() end,
              { desc = "Extract into table", buffer = bufnr }
            )
            map(
              "n",
              prefix .. "f",
              function() crates.show_features_popup() end,
              { desc = "Show features popup", buffer = bufnr }
            )
            map(
              "n",
              prefix .. "d",
              function() crates.show_dependencies_popup() end,
              { desc = "Show dependencies popup", buffer = bufnr }
            )
            map(
              "n",
              prefix .. "v",
              function() crates.show_versions_popup() end,
              { desc = "Show versions popup", buffer = bufnr }
            )
            map(
              "n",
              prefix .. "d",
              function() crates.open_documentation() end,
              { desc = "Open crate documentation", buffer = bufnr }
            )
            map(
              "n",
              prefix .. "l",
              function() crates.open_lib_rs() end,
              { desc = "Open lib.rs of current crate", buffer = bufnr }
            )
            map("n", prefix .. "t", function() crates.toggle() end, { desc = "Toggle Crates.nvim", buffer = bufnr })
          end,
          actions = true,
          completion = true,
          hover = true,
        },
      })
    end,
  },
}
