-- neotex.config.markdown_view
-- Per-buffer "view" mode for markdown: the rendered output is shown on every
-- line, including the cursor line. The raw markdown source is never revealed
-- by anti-conceal, and concealcursor is set so markup is hidden under the cursor.
-- Toggle with <leader>uv (current buffer only).

local M = {}

-- Overrides applied on top of the render-markdown.nvim config for view buffers
local view_overrides = {
  anti_conceal = { enabled = false },
  win_options = {
    conceallevel = { rendered = 3 },
    concealcursor = { rendered = "nc" },
  },
}

function M.is_on(buf)
  return vim.b[buf or 0].markdown_view == true
end

function M.toggle(buf)
  buf = (buf and buf ~= 0) and buf or vim.api.nvim_get_current_buf()
  local ok_state, state = pcall(require, "render-markdown.state")
  local ok_api, api = pcall(require, "render-markdown.api")
  if not (ok_state and ok_api) then
    vim.notify("render-markdown.nvim is not available", vim.log.levels.WARN)
    return
  end

  local on = not M.is_on(buf)
  vim.b[buf].markdown_view = on

  -- Drop the cached per-buffer config so it is rebuilt with/without overrides
  state.cache[buf] = nil
  api.render({
    buf = buf,
    config = on and view_overrides or nil,
  })

  vim.notify("Markdown view mode: " .. (on and "ON" or "OFF"), vim.log.levels.INFO)
end

function M.setup()
  vim.api.nvim_create_user_command("MarkdownViewToggle", function()
    M.toggle()
  end, { desc = "Toggle markdown view mode for current buffer" })

  vim.keymap.set("n", "<leader>uv", function()
    M.toggle()
  end, { silent = true, desc = "Toggle markdown view mode" })

  return true
end

return M
