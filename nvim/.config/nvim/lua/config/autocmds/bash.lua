local augroup = require('utils').augroup

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup("bash"),
  pattern = "*.sh",
  callback = function()
      vim.keymap.set("n", "<leader>mx", "<cmd>!chmod +x %<CR>", {
  	    silent = true,
	    desc = "make bash script executable",})
    end,
  })
