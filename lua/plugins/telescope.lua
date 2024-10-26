-- Telescope is a fuzzy finder that comes with a lot of different things that
-- it can fuzzy find! It's more than just a "file finder", it can search
-- many different aspects of Neovim, your workspace, LSP, and more!
--
-- The easiest way to use telescope, is to start by doing something like:
--  :Telescope help_tags
--
-- After running this command, a window will open up and you're able to
-- type in the prompt window. You'll see a list of help_tags options and
-- a corresponding preview of the help.
--
-- Two important keymaps to use while in telescope are:
--  - Insert mode: <c-/>
--  - Normal mode: ?
--
-- This opens a window that shows you all of the keymaps for the current
-- telescope picker. This is really useful to discover what Telescope can
-- do as well as how to actually do it!

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
return {
  {
    "telescope.nvim",
    cmd = { "Telescope", "LiveGrepGitRoot" },
    -- NOTE: our on attach function defines keybinds that call telescope.
    -- so, the on_require handler will load telescope when we use those.
    on_require = { "telescope" },
    -- event = "",
    -- ft = "",
    keys = {
      { "<leader>fp", mode = { "n" }, desc = "[F]ind git [P]roject root" },
      { "<leader>/",  mode = { "n" }, desc = "[/] Fuzzily search in current buffer" },
      { "<leader>fb", mode = { "n" }, desc = " [F]ind existing [b]uffers" },
      { "<leader>f.", mode = { "n" }, desc = '[F]ind Recent Files ("." for repeat)' },
      { "<leader>fr", mode = { "n" }, desc = "[F]ind [R]esume" },
      { "<leader>fd", mode = { "n" }, desc = "[F]ind [D]iagnostics" },
      { "<leader>fg", mode = { "n" }, desc = "[F]ind by [G]rep" },
      { "<leader>fw", mode = { "n" }, desc = "[F]ind current [W]ord" },
      { "<leader>fs", mode = { "n" }, desc = "[F]ind [S]elect Telescope" },
      { "<leader>ff", mode = { "n" }, desc = "[F]ind [F]iles" },
      { "<leader>fk", mode = { "n" }, desc = "[F]ind [K]eymaps" },
      { "<leader>fh", mode = { "n" }, desc = "[F]ind [H]elp" },
    },
    -- colorscheme = "",
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd("telescope-fzf-native.nvim")
      vim.cmd.packadd("telescope-ui-select.nvim")
    end,
    after = function(plugin)
      require("telescope").setup({
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          mappings = {
            i = { ["<c-enter>"] = "to_fuzzy_refine" },
          },
        },
        -- pickers = {}
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })

      -- Enable telescope extensions, if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      pcall(require("telescope").load_extension, "persisted")

      -- See `:help telescope.builtin`
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find [H]elp" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find [K]eymaps" })
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find [F]iles" })
      vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "Find [S]elect Telescope" })
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find current [W]ord" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find by [G]rep" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find [D]iagnostics" })
      vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Find [R]esume" })
      vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = 'Find Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find existing [b]uffers" })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set("n", "<leader>/", function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "[/] Fuzzily search in current buffer" })

      -- Also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, { desc = "[S]earch [/] in Open Files" })

      -- Telescope live_grep in git root
      -- Function to find the git root directory based on the current buffer's path
      local function find_git_root()
        -- Use the current buffer's path as the starting point for the git search
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir
        local cwd = vim.fn.getcwd()
        -- If the buffer is not associated with a file, return nil
        if current_file == "" then
          current_dir = cwd
        else
          -- Extract the directory from the current file's path
          current_dir = vim.fn.fnamemodify(current_file, ":h")
        end

        -- Find the Git root directory from the current file's path
        local git_root =
            vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
        if vim.v.shell_error ~= 0 then
          print("Not a git repository. Searching on current working directory")
          return cwd
        end
        return git_root
      end

      -- Custom live_grep function to search in git root
      local function live_grep_git_root()
        local git_root = find_git_root()
        if git_root then
          require("telescope.builtin").live_grep({
            search_dirs = { git_root },
          })
        end
      end

      vim.api.nvim_create_user_command("LiveGrepGitRoot", live_grep_git_root, {})
      vim.keymap.set("n", "<leader>sp", live_grep_git_root, { desc = "[S]earch git [P]roject root" })
    end,
  },
}
