local Terminal = require('toggleterm.terminal').Terminal
local python = Terminal:new { cmd = 'python', hidden = true }

vim.keymap.set('n', '<leader>rr', function()
  python:toggle()
end, { buffer = true })
vim.keymap.set('t', '<leader>rr', '<cmd>ToggleTerm<CR>', { buffer = true }) -- In terminal mode
