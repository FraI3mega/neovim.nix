local colorschemeName = nixCats("colorscheme")
-- Could I lazy load on colorscheme with lze?
-- sure. But I was going to call vim.cmd.colorscheme() during startup anyway
-- this is just an example, feel free to do a better job!

if colorschemeName == "catppuccin-mocha" then
  require("catppuccin").setup({
    integrations = {
      neotest = true,
      which_key = true,
      barbar = true,
      aerial = true,
      notify = true,
      neogit = true,
      flash = true,
      diffview = true,
      dap_ui = true,
      dap = true,
      nvim_surround = true,
      noice = true,
      grug_far = true,
      blink_cmp = true,
      markdown = true,
      navic = { enabled = true, custom_bg = "lualine" },
      gitsigns = true,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
          ok = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
          ok = { "underline" },
        },
        inlay_hints = {
          background = true,
        },
      },
    },
  })
end

vim.cmd.colorscheme(colorschemeName)
