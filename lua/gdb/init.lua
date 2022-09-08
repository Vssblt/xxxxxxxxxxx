local app = vim.g.gdb_app_path
local gdb = vim.g.gdb_path
local tty = vim.g.gdb_tty
local gdb_command = {gdb, "-i=mi", "-quiet", {"-iex", "set pagination off"}, {"-iex", "set mi-async on"}, {"-tty", tty }, app}

require'gdb.layout'
require'gdb.command'
