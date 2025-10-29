return {
  -----------------------------------------------------
  -- 🔔 Notification system
  -----------------------------------------------------
  {
    'rcarriga/nvim-notify',
    lazy = false,
    config = function()
      local notify = require 'notify'
      notify.setup {
        stages = 'fade_in_slide_out',

        background_colour = '#1a1b26',
        render = 'default',
        top_down = false,
      }
      vim.notify = notify
    end,
  },
}
