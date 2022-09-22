local i = {}
GdbConfig = {
    project = {
      gdb = "/usr/bin/gdb",
      app = "",
      args = "",
    },
    layout = {
      {
        position = "bottom",
        window = {
            "console",
            "gdb"
        },
        size = 25
      },
      {
        position = "right",
        window = {
            "scope",
            "breakpoints",
            "stack"
        },
        size = 40
      }
    },
    log = "true",
    log_path = "/tmp/light-gdb.log",
  }

function i.setup(obj)
  GdbConfig = GdbConfig or obj
  require'gdb.log'.init()
end

return i
