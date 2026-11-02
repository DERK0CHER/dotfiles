-----------------------------------------------------------
-- Nvim-lint Integration
-- 
-- This module configures nvim-lint for code linting:
-- - Provides filetype-specific linters
-- - Configures key mappings for linting
-- - Supports lint-on-save functionality
-- - Integrates with quickfix and diagnostics
--
-- Nvim-lint is an asynchronous linter plugin for Neovim that works
-- with a variety of linters to maintain code quality.
-----------------------------------------------------------

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "<leader>l", function() require("lint").try_lint() end, desc = "Lint current file" },
  },
  config = function()
    local lint = require("lint")
    
    -- Helper function to check if a command is available
    local function is_executable(command)
      return vim.fn.executable(command) == 1
    end
    
    -- Initialize linters by filetype
    lint.linters_by_ft = {}
    
    -- Only configure linters that are actually available on the system
    -- Web development
    if is_executable("eslint") then
      lint.linters_by_ft.javascript = { "eslint" }
      lint.linters_by_ft.typescript = { "eslint" }
      lint.linters_by_ft.javascriptreact = { "eslint" }
      lint.linters_by_ft.typescriptreact = { "eslint" }
      lint.linters_by_ft.vue = { "eslint" }
    end
    
    if is_executable("stylelint") then
      lint.linters_by_ft.css = { "stylelint" }
    end
    
    if is_executable("tidy") then
      lint.linters_by_ft.html = { "tidy" }
    end
    
    if is_executable("jsonlint") then
      lint.linters_by_ft.json = { "jsonlint" }
    end
    
    if is_executable("yamllint") then
      lint.linters_by_ft.yaml = { "yamllint" }
    end
    
    -- Python
    if is_executable("pylint") then
      lint.linters_by_ft.python = { "pylint" }
    end
    
    -- Lua
    if is_executable("luacheck") then
      lint.linters_by_ft.lua = { "luacheck" }
    end
    
    -- Shell scripting
    if is_executable("shellcheck") then
      lint.linters_by_ft.sh = { "shellcheck" }
      lint.linters_by_ft.bash = { "shellcheck" }
    end
    
    -- Markdown
    if is_executable("markdownlint") then
      lint.linters_by_ft.markdown = { "markdownlint" }
    end
    
    -- LaTeX
    if is_executable("chktex") then
      lint.linters_by_ft.tex = { "chktex" }
    end
    
    -- C/C++
    -- clang-tidy is the primary linter; cppcheck is added too when installed.
    local c_linters = {}

    if is_executable("clang-tidy") then
      table.insert(c_linters, "clangtidy")

      -- Without a compile_commands.json, clang-tidy runs with no flags at all,
      -- which on macOS means it cannot find the system headers and every file
      -- reports "'stdlib.h' file not found". Pointing it at the SDK sysroot
      -- fixes that; --extra-arg is appended whether or not a compilation
      -- database exists, so projects that have one still work normally.
      local extra_args = {
        "--extra-arg=-Wall",
        "--extra-arg=-Wextra",
      }

      if vim.fn.has("mac") == 1 then
        local sdk = vim.fn.system({ "xcrun", "--show-sdk-path" })
        if vim.v.shell_error == 0 then
          sdk = vim.trim(sdk)
          if sdk ~= "" and vim.fn.isdirectory(sdk) == 1 then
            table.insert(extra_args, "--extra-arg=-isysroot" .. sdk)
          end
        end
      end

      -- When clangd is attached it already reports plain compiler diagnostics,
      -- so suppress clang-diagnostic-* here and let clang-tidy contribute only
      -- what clangd does not: the static-analysis checks. Without clangd,
      -- clang-tidy keeps reporting everything.
      if is_executable("clangd") then
        table.insert(extra_args, 1, "--checks=-clang-diagnostic-*")
      end

      -- Keep the builtin cmd/parser, override only the arguments.
      lint.linters.clangtidy = lint.linters.clangtidy or {}
      lint.linters.clangtidy.args = vim.list_extend({ "--quiet" }, extra_args)
    end

    if is_executable("cppcheck") then
      table.insert(c_linters, "cppcheck")
    end

    if #c_linters > 0 then
      lint.linters_by_ft.c = c_linters
      lint.linters_by_ft.cpp = vim.deepcopy(c_linters)
    end
    
    -- Configure linter options only for available linters
    if is_executable("flake8") then
      lint.linters.flake8 = lint.linters.flake8 or {}
      lint.linters.flake8.args = {
        "--max-line-length=88",
        "--extend-ignore=E203",
      }
    end
    
    if is_executable("pylint") then
      lint.linters.pylint = lint.linters.pylint or {}
      lint.linters.pylint.args = {
        "--disable=C0111,C0103,R0903",
        "--output-format=parseable",
        "--reports=no",
      }
      
      -- Only add pylintrc if it exists
      local pylintrc_path = vim.fn.expand("$HOME/.pylintrc")
      if vim.fn.filereadable(pylintrc_path) == 1 then
        table.insert(lint.linters.pylint.args, "--rcfile=" .. pylintrc_path)
      end
      
      -- Add condition to handle parsing errors
      lint.linters.pylint.ignore_exitcode = true
    end
    
    if is_executable("luacheck") then
      lint.linters.luacheck = lint.linters.luacheck or {}
      lint.linters.luacheck.args = {
        "--globals=vim",
        "--no-max-line-length",
      }
    end
    
    -- Helper function to run linters
    _G.lint_try_lint = function()
      -- Try to detect if we're in a Git repository with ESLint configuration
      local is_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true")
      
      if is_git_repo and vim.fn.glob(".eslintrc*") ~= "" then
        -- Use ESLint for all JavaScript-like files in this repository
        if vim.bo.filetype:match("javascript") or vim.bo.filetype:match("typescript") then
          lint.try_lint("eslint")
          return
        end
      end
      
      -- Otherwise, use the regular linting logic
      lint.try_lint()
    end
    
    -- Set up autocommands for running linters
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
      callback = function(args)
        -- Get a list of filetypes that should be automatically linted
        local auto_lint_filetypes = {
          "python",
          "lua",
          "c",
          "cpp",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
        }
        
        -- Check if auto-linting is disabled
        if vim.g.disable_autolint == true then
          return
        end
        
        -- Check if auto-linting is disabled for this buffer
        if vim.b.disable_autolint == true then
          return
        end
        
        -- Check if the current buffer's filetype should be auto-linted
        local filetype = vim.bo.filetype

        -- clang-tidy runs a full static analysis and takes seconds. Linting
        -- C/C++ on every BufEnter makes buffer switching crawl and re-reports
        -- the same findings constantly, so those two lint on save only.
        local save_only = { c = true, cpp = true }
        if args.event == "BufEnter" and save_only[filetype] then
          return
        end

        if vim.tbl_contains(auto_lint_filetypes, filetype) then
          _G.lint_try_lint()
        end
      end,
    })
    
    -- Add user commands for controlling linting
    vim.api.nvim_create_user_command("LintToggle", function(args)
      local is_enabled = false
      if args.args == "buffer" then
        -- Toggle for current buffer
        if vim.b.disable_autolint == true then
          vim.b.disable_autolint = false
          is_enabled = true
        else
          vim.b.disable_autolint = true
          is_enabled = false
        end
        
        require('neotex.util.notifications').lsp('Auto-linting ' .. (is_enabled and 'enabled' or 'disabled') .. ' for this buffer', require('neotex.util.notifications').categories.USER_ACTION)
      else
        -- Toggle globally
        if vim.g.disable_autolint == true then
          vim.g.disable_autolint = false
          is_enabled = true
        else
          vim.g.disable_autolint = true
          is_enabled = false
        end
        
        require('neotex.util.notifications').lsp('Auto-linting ' .. (is_enabled and 'enabled' or 'disabled') .. ' globally', require('neotex.util.notifications').categories.USER_ACTION)
      end
    end, {
      nargs = "?",
      complete = function()
        return { "buffer" }
      end,
      desc = "Toggle auto-linting",
    })
    
    -- LSP diagnostics integration
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })
  end,
}