vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function(args)
    require("circleci.lsp").start(args.buf)
  end,
})
