require("plugins.colorscheme")

require("large_file").setup({
  size_limit = 4 * 1024 * 1024, -- 4 MB
  buffer_options = {
    swapfile = false,
    bufhidden = "unload",
    buftype = "nowrite",
    undolevels = -1,
  },
  on_large_file_read_pre = function(ev) end,
})

require("better_escape").setup()
require("guess-indent").setup({})

require("plugins.completion")

vim.keymap.set("n", "<C-a>", function() require("dial.map").manipulate("increment", "normal") end)
vim.keymap.set("n", "<C-x>", function() require("dial.map").manipulate("decrement", "normal") end)
vim.keymap.set("n", "g<C-a>", function() require("dial.map").manipulate("increment", "gnormal") end)
vim.keymap.set("n", "g<C-x>", function() require("dial.map").manipulate("decrement", "gnormal") end)
vim.keymap.set("v", "<C-a>", function() require("dial.map").manipulate("increment", "visual") end)
vim.keymap.set("v", "<C-x>", function() require("dial.map").manipulate("decrement", "visual") end)
vim.keymap.set("v", "g<C-a>", function() require("dial.map").manipulate("increment", "gvisual") end)
vim.keymap.set("v", "g<C-x>", function() require("dial.map").manipulate("decrement", "gvisual") end)

local augend = require("dial.augend")
require("dial.config").augends:register_group({
  default = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.date.alias["%Y/%m/%d"],
    augend.constant.alias.bool,
    augend.semver.alias.semver,
    augend.date.new({
      pattern = "%B", -- titlecased month names
      default_kind = "day",
    }),
    augend.constant.new({
      elements = {
        "january",
        "february",
        "march",
        "april",
        "may",
        "june",
        "july",
        "august",
        "september",
        "october",
        "november",
        "december",
      },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = {
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
      },
      word = true,
      cyclic = true,
    }),
    augend.constant.new({
      elements = {
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday",
      },
      word = true,
      cyclic = true,
    }),
    augend.case.new({
      types = { "camelCase", "PascalCase", "snake_case", "SCREAMING_SNAKE_CASE" },
    }),
  },
})

require("sort").setup({})
-- mini plugins
require("mini.ai").setup({})
if nixCats("general.extra") then
  -- I didnt want to bother with lazy loading this.
  -- I could put it in opt and put it in a spec anyway
  -- and then not set any handlers and it would load at startup,
  -- but why... I guess I could make it load
  -- after the other lze definitions in the next call using priority value?
  -- didnt seem necessary.

  vim.g.loaded_netrwPlugin = 1
  require("oil").setup({
    default_file_explorer = true,
    columns = {
      "icon",
      "permissions",
      "size",
      -- "mtime",
    },
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-s>"] = "actions.select_vsplit",
      ["<C-h>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
    },
  })
  vim.keymap.set("n", "-", "<cmd>Oil<CR>", { noremap = true, desc = "Open Parent Directory" })
  vim.keymap.set("n", "<leader>-", "<cmd>Oil .<CR>", { noremap = true, desc = "Open nvim root directory" })

  local smart_splits = require("smart-splits")
  smart_splits.setup({
    ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
    ignored_buftypes = { "nofile" },
  })

  vim.keymap.set("n", "<C-H>", function() smart_splits.move_cursor_left() end, { desc = "Move to right split" })
  vim.keymap.set("n", "<C-J>", function() smart_splits.move_cursor_down() end, { desc = "Move to below split" })
  vim.keymap.set("n", "<C-K>", function() smart_splits.move_cursor_up() end, { desc = "Move to above split" })
  vim.keymap.set("n", "<C-L>", function() smart_splits.move_cursor_right() end, { desc = "Move to left split" })
  vim.keymap.set("n", "<A-h>", function() smart_splits.resize_left() end, { desc = "Resize right split" })
  vim.keymap.set("n", "<A-j>", function() smart_splits.resize_down() end, { desc = "Resize below split" })
  vim.keymap.set("n", "<A-k>", function() smart_splits.resize_up() end, { desc = "Resize above split" })
  vim.keymap.set("n", "<A-l>", function() smart_splits.resize_right() end, { desc = "Resize left split" })

  require("persisted").branch = function()
    local branch = vim.fn.systemlist("git branch --show-current")[1]
    return vim.v.shell_error == 0 and branch or nil
  end

  require("persisted").setup({
    use_git_branch = true, -- Include the git branch in the session file name?
    autoload = true, -- Automatically load the session for the cwd on Neovim startup?
  })
  vim.keymap.set("n", "<leader>S", "<cmd>Telescope persisted<cr>", { desc = "Open session picker" })

  vim.opt.sessionoptions:append("globals")
  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "PersistedSavePre",
    group = vim.api.nvim_create_augroup("PersistedHooks", {}),
    callback = function() vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" }) end,
  })
end

require("lze").load({
  { import = "plugins.telescope" },
  { import = "plugins.treesitter" },
  { import = "plugins.noice" },
  { import = "plugins.lines" },
  { import = "plugins.language-specific" },
  { import = "plugins.neotest" },
  { import = "plugins.image" },
  {
    "lazydev.nvim",
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(plugin)
      require("lazydev").setup({
        library = {
          { words = { "nixCats" }, path = (require("nixCats").nixCatsPath or "") .. "/lua" },
        },
      })
    end,
  },
  {
    "hlsearch-nvim",
    event = "BufRead",
    after = function(plugin) require("hlsearch").setup() end,
  },
  {
    "neogen",
    cmd = "Neogen",
    after = function()
      require("neogen").setup({
        snippet_engine = "nvim",
      })
    end,
  },
  {
    "nvim-ufo",
    event = "DeferredUIEnter",
    keys = {
      {
        "zR",
        function() require("ufo").openAllFolds() end,
        desc = "Open all folds",
      },
      {
        "zM",
        function() require("ufo").closeAllFolds() end,
        desc = "Close all folds",
      },
      {
        "zr",
        function() require("ufo").openFoldsExceptKinds() end,
        desc = "Fold less",
      },
      {
        "zm",
        function() require("ufo").closeFoldsWith() end,
        desc = "Fold more",
      },
      {
        "zp",
        function() require("ufo").peekFoldedLinesUnderCursor() end,
        desc = "Peek fold",
      },
    },

    after = function(plugin)
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local totalLines = vim.api.nvim_buf_line_count(0)
        local foldedLines = endLnum - lnum
        local suffix = ("  %d %d%%"):format(foldedLines, foldedLines / totalLines * 100)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        local rAlignAppndx = math.max(math.min(vim.api.nvim_win_get_width(0), width - 1) - curWidth - sufWidth, 0)
        suffix = (" "):rep(rAlignAppndx) .. suffix
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end

      require("ufo").setup({
        fold_virt_text_handler = handler,
        provider_selector = function(_, filetype, buftype)
          local function handleFallbackException(bufnr, err, providerName)
            if type(err) == "string" and err:match("UfoFallbackException") then
              return require("ufo").getFolds(bufnr, providerName)
            else
              return require("promise").reject(err)
            end
          end

          return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
            or function(bufnr)
              return require("ufo")
                .getFolds(bufnr, "lsp")
                :catch(function(err) return handleFallbackException(bufnr, err, "treesitter") end)
                :catch(function(err) return handleFallbackException(bufnr, err, "indent") end)
            end
        end,
      })
    end,
  },
  {
    "heirline.nvim",
    event = "DeferredUIEnter",
    after = function()
      local heirline = require("heirline")
      local heirline_components = require("heirline-components.all")

      -- Setup
      heirline_components.init.subscribe_to_events()
      heirline.load_colors(heirline_components.hl.get_colors())
      heirline.setup({
        statuscolumn = {
          require("heirline-components.all").component.foldcolumn(),
          require("heirline-components.all").component.numbercolumn(),
          require("heirline-components.all").component.signcolumn(),
        },
      })
    end,
  },
  {
    "heirline-components",
    dep_of = "heirline.nvim",
  },
  {
    "grug-far.nvim",
    cmd = "GrugFar",
    after = function(plugin) require("grug-far").setup({}) end,
  },
  {
    "markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = "markdown",
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreview <CR>",
        mode = { "n" },
        noremap = true,
        desc = "markdown preview",
      },
      {
        "<leader>ms",
        "<cmd>MarkdownPreviewStop <CR>",
        mode = { "n" },
        noremap = true,
        desc = "markdown preview stop",
      },
      {
        "<leader>mt",
        "<cmd>MarkdownPreviewToggle <CR>",
        mode = { "n" },
        noremap = true,
        desc = "markdown preview toggle",
      },
    },
    before = function(plugin) vim.g.mkdp_auto_close = 0 end,
  },
  {
    "toggleterm.nvim",
    cmd = "ToggleTerm",
    after = function(plugin) require("toggleterm").setup({}) end,
    keys = {
      { "<leader>t", desc = "[t]erminal" },
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      {
        "<F8>",
        "<cmd>ToggleTerm<cr>",
        desc = "Toggle terminal",
        mode = { "n", "t" },
      },
      {
        "<F8>",
        "<esc><cmd>ToggleTerm<cr>",
        desc = "Toggle terminal",
        mode = { "i" },
      },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle floating terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Toggle vertical terminal" },
    },
  },
  {
    "undotree",
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo" },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" } },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    "comment.nvim",
    event = "DeferredUIEnter",
    after = function(plugin) require("Comment").setup() end,
  },
  {
    "nvim-navic",
    dep_of = "barbecue.nvim",
    after = function(plugin)
      require("nvim-navic").setup({
        lsp = { auto_attach = true },
      })
    end,
  },
  {
    "indent-blankline.nvim",
    event = "DeferredUIEnter",
    cmd = { "IBLEnable", "IBLDisable", "IBLToggle", "IBLEnableScope", "IBLDisableScope", "IBLToggleScope" },
    after = function(plugin)
      require("ibl").setup({
        indent = { char = "▏" },
        scope = { show_start = false, show_end = false },
        exclude = {
          buftypes = {
            "nofile",
            "prompt",
            "quickfix",
            "terminal",
          },
          filetypes = {
            "aerial",
            "alpha",
            "dashboard",
            "help",
            "lazy",
            "mason",
            "neo-tree",
            "NvimTree",
            "neogitstatus",
            "notify",
            "startify",
            "toggleterm",
            "Trouble",
          },
        },
      })
    end,
  },
  {
    "nvim-autopairs",
    event = "InsertEnter",
    after = function(plugin) require("nvim-autopairs").setup({}) end,
  },
  {
    "nvim-surround",
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(plugin) require("nvim-surround").setup() end,
  },
  {
    "vim-startuptime",
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = require("nixCatsUtils").packageBinPath
    end,
  },
  {
    "auto-save",
    event = { "InsertLeave", "TextChanged" },
    cmd = "ASToggle",
    after = function(plugin)
      require("auto-save").setup({
        enabled = vim.env.KITTY_SCROLLBACK_NVIM ~= "true",
        condition = function(buf)
          local fn = vim.fn
          local utils = require("auto-save.utils.data")

          -- don't save for `sql` file types
          if utils.not_in(fn.getbufvar(buf, "&filetype"), { "oil" }) then return true end
          return false
        end,
      })
    end,
  },
  {
    "nvim-tetris",
    cmd = "Tetris",
  },
  {
    "cellular-automaton.nvim",
    cmd = "CellularAutomaton",
  },
  {
    "playtime-nvim",
    cmd = "Playtime",
  },
  {
    "codesnap.nvim",
    keys = {
      { "<leader>Cc", ":'<,'>CodeSnap<CR>", mode = "v", desc = "CodeSnap (clipboard)" },
      { "<leader>Cs", ":'<,'>CodeSnapSave<CR>", mode = "v", desc = "CodeSnap (save)" },
      { "<leader>Ca", ":'<,'>CodeSnapASCII<CR>", mode = "v", desc = "CodeSnap (ASCII)" },
      {
        "<leader>Ch",
        ":'<,'>CodeSnapHighlight<CR>",
        mode = "v",
        desc = "CodeSnap with highlight (clipboard)",
      },
      { "CH", ":'<,'>CodeSnapSaveHighlight<CR>", mode = "v", desc = "CodeSnap with highlight (save)" },
    },
    cmd = { "CodeSnap", "CodeSnapSave", "CodeSnapHighlight", "CodeSnapSaveHighlight", "CodeSnapASCII" },
    after = function(plugin)
      require("codesnap").setup({
        mac_window_bar = true,
        title = "",
        code_font_family = "CaskaydiaCove Nerd Font",
        watermark_font_family = "Pacifico",
        watermark = "",
        bg_theme = "dusk",
        breadcrumbs_separator = "/",
        has_breadcrumbs = true,
        has_line_number = true,
        show_workspace = false,
        min_width = 0,
        bg_x_padding = 122,
        bg_y_padding = 82,
        save_path = os.getenv("XDG_PICTURES_DIR") or (os.getenv("HOME") .. "/Pictures"),
      })
    end,
  },

  {
    "aerial.nvim",
    cmd = { "AerialToggle", "AerialNavToggle" },
    keys = {
      { "<leader>dS", "<cmd>AerialToggle<cr>", mode = "n", desc = "[S]ymbols outline" },
    },
    after = function(plugin) require("aerial").setup({ show_guides = true }) end,
  },
  {
    "cord.nvim",
    event = "DeferredUIEnter",
    after = function(plugin)
      require("cord").setup({
        buttons = { { label = "View Repository", url = "git" } },
        display = { workspace_blacklist = { "franek" } },
        idle = { timeout = 300000 },
      })
    end,
  },
  {
    "kitty-scrollback-nvim",
    event = { "User KittyScrollbackLaunch" },
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    after = function() require("kitty-scrollback").setup() end,
  },
  {
    "twilight.nvim",
    cmd = { "Twilight" },
    dep_of = "zen-mode.nvim",
  },
  {
    "zen-mode.nvim",
    cmd = { "ZenMode" },
    keys = { { "<leader>Z", "<cmd>ZenMode<cr>", desc = "Toggle zen-mode" } },
    after = function(plugin)
      require("zen-mode").setup({
        plugins = {
          options = {
            enabled = true,
            laststatus = 0,
          },
          kitty = {
            enable = true,
            font = "+2",
          },
        },
      })
    end,
  },
  {
    "gitsigns.nvim",
    event = "DeferredUIEnter",
    -- cmd = { "" },
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ "n", "v" }, "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Jump to next hunk" })

          map({ "n", "v" }, "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Jump to previous hunk" })

          -- Actions
          -- visual mode
          map(
            "v",
            "<leader>hs",
            function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
            { desc = "stage git hunk" }
          )
          map(
            "v",
            "<leader>hr",
            function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end,
            { desc = "reset git hunk" }
          )
          -- normal mode
          map("n", "<leader>gs", gs.stage_hunk, { desc = "git stage hunk" })
          map("n", "<leader>gr", gs.reset_hunk, { desc = "git reset hunk" })
          map("n", "<leader>gS", gs.stage_buffer, { desc = "git Stage buffer" })
          map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
          map("n", "<leader>gR", gs.reset_buffer, { desc = "git Reset buffer" })
          map("n", "<leader>gp", gs.preview_hunk, { desc = "preview git hunk" })
          map("n", "<leader>gb", function() gs.blame_line({ full = false }) end, { desc = "git blame line" })
          map("n", "<leader>gD", function() gs.diffthis("~") end, { desc = "git diff against last commit" })

          -- Toggles
          map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
          map("n", "<leader>gtd", gs.toggle_deleted, { desc = "toggle git show deleted" })

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
        end,
      })
    end,
  },
  {
    "neogit",
    event = "DeferredUIEnter",
    keys = {
      { "<leader>gn", mode = "n", desc = "Neogit" },
      { "<leader>gnt", "<cmd>Neogit<cr>", mode = "n", desc = "Open neogit [t]ab page" },
      { "<leader>gnc", "<cmd>Neogit commit<cr>", mode = "n", desc = "Open neogit [c]ommit page" },
    },
    after = function(plugin)
      require("neogit").setup({
        graph_style = vim.env.TERM == "xterm-kitty" and "kitty" or "unicode",
        disable_signs = true,
      })
    end,
  },
  {
    "diffview.nvim",
    cmd = { "DiffviewOpen" },
    dep_of = "neogit",
    before = function(plugin) vim.opt.fillchars:append({ diff = "╱" }) end,
    after = function(plugin) require("diffview").setup({}) end,
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", mode = "n", desc = "Open diffview" },
    },
  },
  {
    "flash.nvim",
    event = "DeferredUIEnter",
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function() require("flash").jump() end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function() require("flash").treesitter() end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function() require("flash").remote() end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc = "Toggle Flash Search",
      },
    },
  },
  {
    "todo-comments.nvim",
    event = "DeferredUIEnter",
    after = function(plugin)
      require("todo-comments").setup({})
      vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find [t]odo" })
    end,
  },
  {
    "trouble.nvim",
    cmd = "Trouble",
    after = function(plugin)
      require("trouble").setup({})

      local open_with_trouble = require("trouble.sources.telescope").open

      -- Use this to add more results without clearing the trouble list

      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          mappings = {
            i = { ["<c-t>"] = open_with_trouble },
            n = { ["<c-t>"] = open_with_trouble },
          },
        },
      })
    end,
    keys = {
      { "<leader>x", desc = "Trouble" },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Trouble Workspace Diagnostics",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Trouble Buffer Diagnostics",
      },
      { "<leader>xt", "<cmd>Trouble todo<cr>", desc = "Trouble Todo" },
      { "<leader>xT", "<cmd>Trouble todo filter={tag={TODO,FIX,FIXME}}<cr>", desc = "Trouble Todo/Fix/Fixme" },
    },
  },

  {
    "which-key.nvim",
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require("which-key").setup({})
      require("which-key").add({
        { "<leader><leader>", group = "buffer" },
        { "<leader>bs", group = "[s]ort" },
        { "<leader>bs_", hidden = true },
        { "<leader>c", group = "[c]ode" },
        { "<leader>c_", hidden = true },
        { "<leader>d", group = "[d]ocument" },
        { "<leader>d_", hidden = true },
        { "<leader>g", group = "[g]it" },
        { "<leader>g_", hidden = true },
        { "<leader>m", group = "[m]arkdown" },
        { "<leader>m_", hidden = true },
        { "<leader>r", group = "[r]ename" },
        { "<leader>r_", hidden = true },
        { "<leader>s", group = "[s]earch" },
        { "<leader>s_", hidden = true },
        { "<leader>t", group = "[t]oggles" },
        { "<leader>t_", hidden = true },
        { "<leader>w", group = "[w]orkspace" },
        { "<leader>w_", hidden = true },
        -- { "<leader>T",         group = "[T]ests" },
        -- { "<leader>T_",        hidden = true },
      })
    end,
  },
})
