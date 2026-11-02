-----------------------------------------------------
-- nvim-surround - Surround text with quotes, brackets, and more
--
-- This plugin provides mappings to easily surround items with pairs
-- like (), [], {}, etc. It's a replacement for mini.surround, which
-- had issues with key binding conflicts.
--
-- Default mappings:
-- - ys{motion}{char} - Add surround around motion
-- - ds{char} - Delete surround character
-- - cs{old}{new} - Change surround from old to new
--
-- Examples:
-- - ysiw" - Surround word with quotes
-- - ds{ - Delete surrounding {} braces
-- - cs"' - Change surrounding quotes from double to single
--
-- Visual Mode:
-- - S{char} - Surround selected text
-----------------------------------------------------

return {
  "kylechui/nvim-surround", 
  version = "*",  -- Use the latest stable release 
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Keymaps (ys, yss, yS, ySS, S, gS, ds, cs, <C-g>s, <C-g>S) are the plugin
      -- defaults; since v4 they can no longer be passed to setup().
      
      -- Configure LaTeX surroundings
      surrounds = {
        -- LaTeX specific surroundings
        ["E"] = {
          add = function()
            return { { "\\begin{" .. vim.fn.input("Environment: ") .. "}" }, { "\\end{" .. vim.fn.input("Environment: ") .. "}" } }
          end,
        },
        ["$"] = {
          add = { "$", "$" },
          find = "%$.-[^\\]%$",
          delete = "^(.)().-(.)()$"
        },
        ["i"] = {
          add = { "\\textit{", "}" },
        },
        ["b"] = {
          add = { "\\textbf{", "}" },
        },
        ["t"] = {
          add = { "\\texttt{", "}" },
        },
        ["u"] = {
          add = { "\\underline{", "}" },
        },
        ["q"] = {
          add = { "``", "''" },  -- LaTeX quotes
        },
        ["Q"] = {
          add = { "`", "'" },    -- LaTeX single quotes
        },
      },
      
      -- Aliases configure alternative names for surrounds
      aliases = {
        ["b"] = { ")", "]", "}", ">", "〉", "」", "』", "〕", "】", "〗", "〙", "〛", "❯" },
        ["q"] = { "'", '"', "`" },
      },
    })
  end,
}