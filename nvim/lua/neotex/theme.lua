-- Theme state shared with the fish `theme` command.
-- State file: ~/.local/state/theme/current  ("default" | "calm")
local M = {}

M.state_file = vim.fn.expand("~/.local/state/theme/current")

function M.current()
  local f = io.open(M.state_file, "r")
  if not f then return "default" end
  local name = (f:read("*l") or ""):gsub("%s+", "")
  f:close()
  return (name == "calm") and "calm" or "default"
end

-- Grey/white palette matching kitty/themes/calm.conf
local calm = {
  bg = "#2e3033", bg1 = "#393b3e", bg2 = "#45474b", bg3 = "#55585c", bg4 = "#6a6d71",
  fg = "#f0f0f0", fg2 = "#dadada", fg3 = "#c4c4c4", fg4 = "#aaaaaa", gray = "#8a8d91",
  red = "#c48585", green = "#9fb38a", yellow = "#d4be8a", blue = "#8fa8c4",
  purple = "#b39bc0", aqua = "#8fbfbd", orange = "#cfa080",
}

local function gruvbox_setup(name)
  if name == "calm" then
    local c = calm
    require("gruvbox").setup({
      contrast = "",
      italic = { strings = false, comments = true, operators = false, folds = true },
      palette_overrides = {
        dark0 = c.bg, dark0_hard = c.bg, dark0_soft = c.bg,
        dark1 = c.bg1, dark2 = c.bg2, dark3 = c.bg3, dark4 = c.bg4,
        light0 = c.fg, light0_hard = c.fg, light0_soft = c.fg,
        light1 = c.fg, light2 = c.fg2, light3 = c.fg3, light4 = c.fg4,
        gray = c.gray,
        bright_red = c.red, bright_green = c.green, bright_yellow = c.yellow,
        bright_blue = c.blue, bright_purple = c.purple, bright_aqua = c.aqua,
        bright_orange = c.orange,
        neutral_red = c.red, neutral_green = c.green, neutral_yellow = c.yellow,
        neutral_blue = c.blue, neutral_purple = c.purple, neutral_aqua = c.aqua,
        neutral_orange = c.orange,
      },
      overrides = {
        SignColumn = { bg = c.bg },
        NvimTreeCutHL = { fg = c.red, bg = c.bg },
        NvimTreeCopiedHL = { fg = c.green, bg = c.bg },
        DiagnosticSignError = { fg = c.red, bg = c.bg },
        DiagnosticSignWarn = { fg = c.yellow, bg = c.bg },
        DiagnosticSignHint = { fg = c.aqua, bg = c.bg },
        DiagnosticSignInfo = { fg = c.purple, bg = c.bg },
        DiffText = { fg = c.fg, bg = c.bg2 },
        DiffAdd = { fg = c.fg, bg = "#3a4236" },
      },
    })
  else
    -- Original setup, unchanged
    require("gruvbox").setup({
      overrides = {
        SignColumn = { bg = "#282828" },
        NvimTreeCutHL = { fg = "#fb4934", bg = "#282828" },
        NvimTreeCopiedHL = { fg = "#b8bb26", bg = "#282828" },
        DiagnosticSignError = { fg = "#fb4934", bg = "#282828" },
        DiagnosticSignWarn = { fg = "#fabd2f", bg = "#282828" },
        DiagnosticSignHint = { fg = "#8ec07c", bg = "#282828" },
        DiagnosticSignInfo = { fg = "#d3869b", bg = "#282828" },
        DiffText = { fg = "#ebdbb2", bg = "#3c3836" },
        DiffAdd = { fg = "#ebdbb2", bg = "#32361a" },
      },
    })
  end
end

-- Which gruvbox variant was applied via M.apply (nil = another colorscheme is active)
M.active = nil

function M.lualine_theme(name)
  name = name or M.active
  if name == nil then return "auto" end      -- e.g. nightfly: lualine picks its theme
  if name ~= "calm" then return "gruvbox" end
  local c = calm
  local function mode(color)
    return {
      a = { fg = c.bg, bg = color, gui = "bold" },
      b = { fg = c.fg, bg = c.bg2 },
      c = { fg = c.fg2, bg = c.bg1 },
    }
  end
  return {
    normal = mode(c.fg3),
    insert = mode(c.blue),
    visual = mode(c.yellow),
    replace = mode(c.red),
    command = mode(c.green),
    inactive = {
      a = { fg = c.gray, bg = c.bg1 },
      b = { fg = c.gray, bg = c.bg1 },
      c = { fg = c.gray, bg = c.bg1 },
    },
  }
end

-- Apply theme (reads state file when name is nil). Safe to call at runtime.
function M.apply(name)
  name = name or M.current()
  M.active = name
  vim.o.background = "dark"
  gruvbox_setup(name)
  vim.cmd("colorscheme gruvbox")
  local ok, lualine = pcall(require, "lualine")
  if ok and package.loaded["lualine"] then
    local cfg = lualine.get_config()
    cfg.options.theme = M.lualine_theme(name)
    lualine.setup(cfg)
  end
end

vim.api.nvim_create_user_command("Theme", function(opts)
  local name = opts.args ~= "" and opts.args or M.current()
  M.apply(name)
end, {
  nargs = "?",
  complete = function() return { "default", "calm" } end,
  desc = "Apply theme (default|calm); without args re-read ~/.local/state/theme/current",
})

return M
