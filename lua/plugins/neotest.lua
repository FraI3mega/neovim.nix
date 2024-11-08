local prefix = "<leader>T"
local watch = prefix .. "w"
local get_file_path = function() return vim.fn.expand("%") end
local get_project_path = function() return vim.fn.getcwd() end
return {
  {
    "neotest",
    load = function(name)
      vim.cmd.packadd("plenary-nvim")
      vim.cmd.packadd("nvim-nio")
      vim.cmd.packadd("nvim-treesitter")
      vim.cmd.packadd(name)
    end,

    keys = {
      { prefix, desc = "[T]est" },
      { prefix .. "r", desc = "[r]un test" },
      { prefix .. "d", desc = "[d]ebug test" },
      { prefix .. "f", desc = "Run all test in [f]ile" },
      { prefix .. "p", desc = "Run all test in [p]roject" },
      { prefix .. "<CR>", desc = "Test summary" },
      { prefix .. "o", desc = "output hover" },
      { prefix .. "O", desc = "output windows" },
      { "]T", desc = "Next [T]est" },
      { "[T", desc = "Previous [T]est" },
      { watch, desc = "[w]atch tests" },
      { watch .. "t", desc = "toggle watch [t]est" },
      { watch .. "f", desc = "toggle watch all tests in [f]ile" },
      { watch .. "p", desc = "toggle watch all tests in [p]roject" },
    },

    after = function(plugin)
      local neotest = require("neotest")

      neotest.setup({
        adapters = {
          require("rustaceanvim.neotest"),
        },
      })

      vim.keymap.set("n", prefix .. "r", function() neotest.run.run() end, { desc = "[r]un test" })
      vim.keymap.set(
        "n",
        prefix .. "d",
        function() neotest.run.run({ strategy = "dap" }) end,
        { desc = "[d]ebug test" }
      )
      vim.keymap.set(
        "n",
        prefix .. "f",
        function() neotest.run.run(get_file_path()) end,
        { desc = "Run all test in [f]ile" }
      )
      vim.keymap.set(
        "n",
        prefix .. "p",
        function() neotest.run.run(get_project_path()) end,
        { desc = "Run all test in [p]roject" }
      )
      vim.keymap.set("n", prefix .. "<CR>", function() neotest.summary.toggle() end, { desc = "Test summary" })
      vim.keymap.set("n", prefix .. "o", function() require("neotest").output.open() end, { desc = "output hover" })
      vim.keymap.set(
        "n",
        prefix .. "O",
        function() require("neotest").output_panel.toggle() end,
        { desc = "output windows" }
      )
      vim.keymap.set("n", "]T", function() require("neotest").jump.next() end, { desc = "Next [T]est" })
      vim.keymap.set("n", "[T", function() require("neotest").jump.prev() end, { desc = "Previous [T]est" })
    end,
  },
}
