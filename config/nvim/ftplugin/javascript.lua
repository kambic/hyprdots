local Terminal = require('toggleterm.terminal').Terminal
local node = Terminal:new { cmd = 'node', hidden = true }

vim.keymap.set('n', '<leader>rr', function()
  node:toggle()
end, { buffer = true })
vim.keymap.set('t', '<leader>rr', '<cmd>ToggleTerm<CR>', { buffer = true })
