---@module 'blink.cmp'
---@type blink.cmp.Config

-- NOTE: packadd doesnt load after directories.
-- hence, the above function that you can get from luaUtils that exists to make that easy.

require("blink-cmp").setup({
  keymap = { preset = "enter" },
  accept = { auto_brackets = { enabled = true } },
  trigger = { signature_help = { enabled = true } },
  windows = {
    documentation = { auto_show = true },
    autocomplete = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } } } },
  },
  fuzzy = { prebuilt_binaries = { download = false } },
  sources = {
    -- add lazydev to your completion providers
    completion = {
      enabled_providers = { "lsp", "path", "snippets", "buffer", "lazydev" },
    },
    providers = {
      -- dont show LuaLS require statements when lazydev has items
      lsp = { fallback_for = { "lazydev" } },
      lazydev = { name = "LazyDev", module = "lazydev.integrations.blink" },
    },
  },
})
