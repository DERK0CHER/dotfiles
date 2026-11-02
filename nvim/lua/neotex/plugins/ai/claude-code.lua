return {
  "coder/claudecode.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    port_range = { min = 10000, max = 65535 },
    auto_start = true,
    log_level = "warn",
    track_selection = true,
    focus_after_send = false,

    terminal = {
      split_side = "right",
      split_width_percentage = 0.35,
      provider = "auto",  -- uses snacks if available, falls back to native
      auto_close = true,
    },

    diff_opts = {
      layout = "vertical",
      open_in_new_tab = false,
      keep_terminal_focus = false,
      on_new_file_reject = "close_window",
    },
  },

  -- NOTE: Key mappings are defined in which-key.lua under the AI HELP group
  keys = {},

  config = function(_, opts)
    require("claudecode").setup(opts)

    vim.api.nvim_create_user_command("ClaudeCodeAddBuffer", function()
      local file = vim.fn.expand("%:p")
      if file ~= "" then
        vim.cmd("ClaudeCodeAdd " .. vim.fn.fnameescape(file))
      else
        require('neotex.util.notifications').ai('No file to add to Claude context', require('neotex.util.notifications').categories.WARNING)
      end
    end, { desc = "Add current buffer to Claude Code context" })

    vim.api.nvim_create_user_command("ClaudeCodeAddDir", function()
      vim.cmd("ClaudeCodeAdd " .. vim.fn.fnameescape(vim.fn.getcwd()))
    end, { desc = "Add current directory to Claude Code context" })
  end,
}