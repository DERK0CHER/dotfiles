-- Keep a per-directory session up to date while running inside tmux, so that
-- tmux-resurrect can reopen nvim with all files after a reboot
-- (tmux.conf restores nvim as `nvim +TmuxSessionRestore`).
local M = {}

local function sm()
  local ok, mod = pcall(require, "session_manager")
  return ok and mod or nil
end

local function has_real_buffers()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted and vim.bo[b].buftype == "" and vim.api.nvim_buf_get_name(b) ~= "" then
      return true
    end
  end
  return false
end

function M.save()
  local m = sm()
  if m and has_real_buffers() then pcall(m.save_current_session) end
end

function M.setup()
  vim.api.nvim_create_user_command("TmuxSessionRestore", function()
    local m = sm()
    if not m then
      pcall(function() require("lazy").load({ plugins = { "neovim-session-manager" } }) end)
      m = sm()
    end
    if m and m.current_dir_session_exists() then
      m.load_current_dir_session(true)
    end
  end, { desc = "Restore this directory's session (used by tmux-resurrect)" })

  if not vim.env.TMUX then return end
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "FocusLost", "VimLeavePre" }, {
    group = vim.api.nvim_create_augroup("TmuxSessionAutosave", { clear = true }),
    callback = function(ev)
      if ev.event == "VimLeavePre" then return M.save() end
      -- debounce: at most once every 10s except on exit
      local now = vim.uv.now()
      if M._last and now - M._last < 10000 then return end
      M._last = now
      vim.schedule(M.save)
    end,
  })
end

return M
