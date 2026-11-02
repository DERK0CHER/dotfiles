return {
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    event = "InsertEnter",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function() end, -- Empty config to prevent auto-loading
      },
    },
    build = "make install_jsregexp", -- Important for NixOS
    config = function()
      -- Set all disabling flags before requiring luasnip
      vim.g.luasnip_no_community_snippets = true
      vim.g.luasnip_no_jsregexp = true
      vim.g.luasnip_no_vscode_loader = true

      -- Initialize LuaSnip with minimal configuration
      local ls = require("luasnip")
      ls.setup({
        history = true,
        update_events = "TextChanged,TextChangedI",
        enable_autosnippets = true,

        -- Without these, a finished snippet's session stays alive forever, so
        -- <Tab> keeps jumping back into placeholders of snippets you left long
        -- ago. region_check unlinks the session once the cursor leaves the
        -- snippet's text; delete_check drops it when its nodes are deleted.
        region_check_events = "CursorMoved,CursorMovedI,InsertLeave",
        delete_check_events = "TextChanged,InsertLeave",
      })

      -- Load snippets immediately
      local ok, loader = pcall(require, "luasnip.loaders.from_snipmate")
      if ok and loader then
        loader.load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
      end
    end
  }
}
