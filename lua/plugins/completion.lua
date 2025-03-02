---@module 'blink.cmp'
---@type blink.cmp.Config

-- NOTE: packadd doesnt load after directories.
-- hence, the above function that you can get from luaUtils that exists to make that easy.

require("blink-cmp").setup({
  keymap = {
    preset = "enter",
  },
  cmdline = { completion = { ghost_text = { enabled = true } } },
  completion = {
    accept = { auto_brackets = { enabled = true } },

    documentation = { auto_show = true },
    menu = {
      draw = {
        components = {
          kind_icon = {
            ellipsis = false,
            text = function(ctx)
              local lspkind = require("lspkind")
              local icon = ctx.kind_icon
              if vim.tbl_contains({ "Path" }, ctx.source_name) then
                local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                if dev_icon then icon = dev_icon end
              else
                icon = require("lspkind").symbolic(ctx.kind, {
                  mode = "symbol",
                })
              end

              return icon .. ctx.icon_gap
            end,

            -- Optionally, use the highlight groups from nvim-web-devicons
            -- You can also add the same function for `kind.highlight` if you want to
            -- keep the highlight groups in sync with the icons.
            highlight = function(ctx)
              local hl = ctx.kind_hl
              if vim.tbl_contains({ "Path" }, ctx.source_name) then
                local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                if dev_icon then hl = dev_hl end
              end
              return hl
            end,
          },
        },
      },
    },
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
