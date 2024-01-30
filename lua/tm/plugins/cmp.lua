local snippets_engine = {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  dependencies = {
    "rafamadriz/friendly-snippets", -- snippet provider
  },
  build = vim.fn.has("win31") ~= 0 and "make install_jsregexp" or nil,
}

local completion_sources = {
  "hrsh7th/cmp-buffer", -- buffer source
  "hrsh7th/cmp-path", -- path source
  "hrsh7th/cmp-nvim-lsp", -- lsp source
  "saadparwaiz1/cmp_luasnip", -- luasnip source
  "hrsh7th/cmp-emoji", -- emoji source
  {
    "David-Kunz/cmp-npm",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "json",
    config = true,
  }, -- npm package source
}

local M = {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    snippets_engine,
    completion_sources,
    "onsails/lspkind.nvim", -- vs-code like icons
  },
}

function M.config()
  require("luasnip.loaders.from_vscode").lazy_load()

  local cmp = require("cmp")

  cmp.setup({
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "npm", keyword_length = 4 },
      { name = "path", max_item_count = 3 },
      { name = "emoji" },
    }, {
      { name = "buffer", max_item_count = 5 },
    }),
    formatting = {
      fields = { "abbr", "kind", "menu" },
      format = require("lspkind").cmp_format({
        mode = "symbol", -- show only symbol annotations
        maxwidth = 50, -- prevent the popup from showing more than provided characters
        ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
        symbol_map = {
          emoji = "",
        },
      }),
      expandable_indicator = true,
    },
    window = {
      completion = cmp.config.window.bordered({
        scrollbar = false,
      }),
      documentation = cmp.config.window.bordered({
        scrollbar = false,
        max_height = 30,
      }),
    },
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<Tab>"] = cmp.mapping.confirm({ select = true }),
      ["<CR>"] = cmp.mapping.confirm({ select = false }),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.close(),
    }),
  })
end

return M
