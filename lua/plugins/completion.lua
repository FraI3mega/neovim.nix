---@module 'blink.cmp'
---@type blink.cmp.Config

-- NOTE: packadd doesnt load after directories.
-- hence, the above function that you can get from luaUtils that exists to make that easy.

require("blink-cmp").setup({
  keymap = {
    cmdline = {
      preset = "super-tab",
    },
    preset = "enter",
  },
  completion = {
    accept = { auto_brackets = { enabled = true } },

    documentation = { auto_show = true },
    menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } } } },
  },
  -- signature = { enabled = true },
  fuzzy = { prebuilt_binaries = { download = false } },
  sources = {
    -- add lazydev to your completion providers
    default = { "lsp", "path", "snippets", "buffer", "lazydev" },
    providers = {
      -- dont show LuaLS require statements when lazydev has items
      lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", fallbacks = { "lsp" } },
    },
  },
})
