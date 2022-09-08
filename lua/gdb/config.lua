local config = {}

function config:init(c)
  c = c or { { position = "top", layout = { "console", "gdb" }, size = 0.2 }, { position = "right", layout = { "scope", "breakpoints", "stack" }, size = 0.2 } }

end



return config
