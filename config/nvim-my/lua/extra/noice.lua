return {
  {
    'rcarriga/nvim-notify',
    config = function()
      require('notify').setup {
        background_colour = 'Normal',
      }
      vim.notify = require 'notify'
    end,
  },
  -- lazy.nvim
  {
    'folke/noice.nvim',
    event = 'verylazy',
    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      routes = {
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+l, %d+b' },
              { find = '; after #%d+' },
              { find = '; before #%d+' },
            },
          },
          view = 'mini',
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'muniftanjim/nui.nvim',
      -- optional:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   if not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
  },
}
