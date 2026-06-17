-- vim ui2 (requires nvim 0.12+)
pcall(function()
  require('vim._core.ui2').enable({
    enable = true,
    msg = {
        target = "cmd", -- options: cmd(classic), msg(similar to noice)
        pager = { height = 1 },
        msg   = { height = 0.5, timeout = 4500 },
        dialog = { height = 0.5 },
        cmd    = { height = 0.5 },
    },
})
end)

require("eakhkon.core")
require("eakhkon.lazy")
require("current-theme")
