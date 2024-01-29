local M = {
  "kevinhwang91/nvim-ufo",
  event = { "LspAttach" },
  dependencies = {
    "kevinhwang91/promise-async",
  },
}

function M.config()
  vim.o.foldcolumn = "0" -- '0' is not bad, hide it!
  vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true
  vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

  -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
  vim.keymap.set("n", "zR", require("ufo").openAllFolds)
  vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

  local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (" 󰡏 %d "):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if targetWidth > curWidth + chunkWidth then
        table.insert(newVirtText, chunk)
      else
        chunkText = truncate(chunkText, targetWidth - curWidth)
        local hlGroup = chunk[2]
        table.insert(newVirtText, { chunkText, hlGroup })
        chunkWidth = vim.fn.strdisplaywidth(chunkText)
        -- str width returned from truncate() may less than 2nd argument, need padding
        if curWidth + chunkWidth < targetWidth then
          suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
        end
        break
      end
      curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, "MoreMsg" })
    return newVirtText
  end

  local ftMap = {
    typescriptreact = { "lsp", "treesitter" },
    python = { "indent" },
    git = "",
  }

  require("ufo").setup({
    open_fold_hl_timeout = 0,
    enable_get_fold_virt_text = true,
    fold_virt_text_handler = handler,
    close_fold_kinds = {},
    provider_selector = function(_, filetype, _)
      return ftMap[filetype]
    end,
    preview = {
      win_config = {
        border = "rounded",
        winhighlight = "Normal:Folded",
        winblend = 0,
      },
      mappings = {
        scrollU = "<C-k>",
        scrollD = "<C-j>",
        jumpTop = "[",
        jumpBot = "]",
      },
    },
  })

  vim.keymap.set("n", "zR", require("ufo").openAllFolds)
  vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
  vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
  vim.keymap.set("n", "zm", require("ufo").closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
  vim.keymap.set("n", "K", function()
    local winid = require("ufo").peekFoldedLinesUnderCursor()
    if not winid then
      vim.lsp.buf.hover()
    end
  end)
end

return M
