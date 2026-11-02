-- neotex.config.readonly
-- Global read-only mode: blocks edits and writes in all normal file buffers.
-- Toggle with :ReadOnlyToggle or <leader>uR. Original per-buffer state is
-- remembered and restored when the mode is turned off.

local M = {}

M.enabled = false

-- bufnr -> { modifiable = bool, readonly = bool }
local saved = {}

local function is_file_buffer(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].buflisted
end

local function apply(buf)
  if not is_file_buffer(buf) or saved[buf] then
    return
  end
  saved[buf] = {
    modifiable = vim.bo[buf].modifiable,
    readonly = vim.bo[buf].readonly,
  }
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
end

local function restore(buf)
  local prev = saved[buf]
  if not prev then
    return
  end
  if vim.api.nvim_buf_is_valid(buf) then
    vim.bo[buf].modifiable = prev.modifiable
    vim.bo[buf].readonly = prev.readonly
  end
  saved[buf] = nil
end

function M.enable()
  M.enabled = true
  vim.g.readonly_mode = true
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    apply(buf)
  end
  vim.notify("Read-only mode: ON", vim.log.levels.INFO)
end

function M.disable()
  M.enabled = false
  vim.g.readonly_mode = false
  for buf in pairs(vim.deepcopy(saved)) do
    restore(buf)
  end
  vim.notify("Read-only mode: OFF", vim.log.levels.INFO)
end

function M.toggle()
  if M.enabled then
    M.disable()
  else
    M.enable()
  end
end

function M.setup()
  vim.api.nvim_create_user_command("ReadOnlyToggle", function()
    M.toggle()
  end, { desc = "Toggle global read-only mode" })

  -- Apply to buffers opened while read-only mode is on
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    group = vim.api.nvim_create_augroup("NeotexReadOnlyMode", { clear = true }),
    callback = function(ev)
      if M.enabled then
        apply(ev.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufDelete", {
    group = "NeotexReadOnlyMode",
    callback = function(ev)
      saved[ev.buf] = nil
    end,
  })

  vim.keymap.set("n", "<leader>uR", M.toggle, { silent = true, desc = "Toggle read-only mode" })

  return true
end

return M
