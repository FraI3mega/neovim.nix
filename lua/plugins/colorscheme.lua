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
      notify = true,
      neogit = true,
      diffview = true,
      fidget = true,
    },
  })
end

vim.cmd.colorscheme(colorschemeName)
