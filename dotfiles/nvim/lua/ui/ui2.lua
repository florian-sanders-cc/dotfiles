-- nvim 0.13 moved some ui2 settings into the 'messagesopt' option:
--   msg.cmd.height  -> maxheight (percentage of 'lines', not a fraction)
--   msg.msg.timeout -> timeout
--   pager_char      -> pager
-- 'history' must always be present; keep the other defaults as shipped.
vim.o.messagesopt = "hit-enter,history:500,progress:c,maxheight:50,timeout:4000"

require("vim._core.ui2").enable({
  enable = true,
  msg = {
    targets = "cmd",
    dialog = {
      height = 0.5,
    },
    msg = {
      height = 0.5,
    },
    pager = {
      height = 1,
    },
  },
})
