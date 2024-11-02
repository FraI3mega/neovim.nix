---packadd + after/plugin
---@type fun(names: string[]|string)

-- NOTE: packadd doesnt load after directories.
-- hence, the above function that you can get from luaUtils that exists to make that easy.

require("blink.cmp").setup({
  keymap = { preset = "default" },
  accept = { auto_brackets = { enabled = true } },
  trigger = { signature_help = { enabled = true } },
  windows = {documentation = {auto_show = true}},
  nerd_font_variant = 'normal',
})
