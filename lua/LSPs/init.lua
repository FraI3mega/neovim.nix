local servers = {}
if nixCats("neonixdev") then
  servers.lua_ls = {
    Lua = {
      formatters = {
        enabled = false,
      },
      signatureHelp = { enabled = true },
      diagnostics = {
        globals = { "nixCats" },
        disable = { "missing-fields" },
      },
    },
    telemetry = { enabled = false },
    filetypes = { "lua" },
  }
  servers.nixd = {
    nixd = {
      nixpkgs = {
        -- nixd requires some configuration in flake based configs.
        -- luckily, the nixCats plugin is here to pass whatever we need!
        expr = [[import (builtins.getFlake "]] .. nixCats("nixdExtras.nixpkgs") .. [[") { }   ]],
      },
      formatting = {
        command = { "alejandra" },
      },
      diagnostic = {
        suppress = {
          "sema-escaping-with",
        },
      },
    },
  }
  -- If you integrated with your system flake,
  -- you should pass inputs.self.outPath as nixdExtras.flake-path
  -- that way it will ALWAYS work, regardless
  -- of where your config actually was.
  -- otherwise flake-path could be an absolute path to your system flake, or nil or false
  if nixCats("nixdExtras.flake-path") and nixCats("nixdExtras.systemCFGname") and nixCats("nixdExtras.homeCFGname") then
    servers.nixd.nixd.options = {
      -- (builtins.getFlake "<path_to_system_flake>").nixosConfigurations."<name>".options
      nixos = {
        expr = [[(builtins.getFlake "]] .. nixCats("nixdExtras.flake-path") .. [[").nixosConfigurations."]] .. nixCats(
          "nixdExtras.systemCFGname"
        ) .. [[".options]],
      },
      -- (builtins.getFlake "<path_to_system_flake>").homeConfigurations."<name>".options
    }
  end
  if not nixCats("nixdExtras.homeCFGname") then
    servers.nixd.nixd.options = {
      ["home-manager"] = {
        expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.whitey.options',
      },
    }
  else
    servers.nixd.nixd.options = {
      ["home-manager"] = {
        expr = [[(builtins.getFlake "]] .. nixCats("nixdExtras.flake-path") .. [[").homeConfigurations."]] .. nixCats(
          "nixdExtras.homeCFGname"
        ) .. [[".options]],
      },
    }
  end
else
  servers.rnix = {}
  servers.nil_ls = {}
end

-- This is this flake's version of what kickstarter has set up for mason handlers.
-- This is a convenience function that calls lspconfig on the lsps we downloaded via nix
-- This will not download your lsp. Nix does that.

--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--  All of them are listed in https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
--  You may do the same thing with cmd

-- servers.clangd = {},
-- servers.gopls = {},
-- servers.pyright = {},
-- servers.rust_analyzer = {},
-- servers.tsserver = {},
-- servers.html = { filetypes = { 'html', 'twig', 'hbs'} },

-- If you were to comment out this autocommand
-- and instead pass the on attach function directly to
-- nvim-lspconfig, it would do the same thing.
-- come to think of it, it might be better because then lspconfig doesnt have to be called before lsp attach?
-- but you would still end up triggering on a FileType event anyway, so, it makes little difference.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("nixCats-lsp-attach", { clear = true }),
  callback = function(event)
    require("LSPs.caps-on_attach").on_attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
  end,
})

require("lze").load({
  {
    "nvim-lspconfig",
    event = "FileType",
    after = function(plugin)
      for server_name, cfg in pairs(servers) do
        require("lspconfig")[server_name].setup({
          capabilities = vim.tbl_extend("keep", require("blink.cmp").get_lsp_capabilities(cfg.capabilities), {
            textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } },
          }),
          -- capabilities = require("LSPs.caps-on_attach").get_capabilities(server_name),
          -- this line is interchangeable with the above LspAttach autocommand
          -- on_attach = require('LSPs.caps-on_attach').on_attach,
          settings = cfg,
          filetypes = (cfg or {}).filetypes,
          cmd = (cfg or {}).cmd,
          root_pattern = (cfg or {}).root_pattern,
        })
      end
    end,
  },
})

local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
require("LSPs.otter")
