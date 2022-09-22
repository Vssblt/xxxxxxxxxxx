local log = {}
function log.init()
  local log = nil
  local log_path = nil
  if GdbConfig == nil then
    log = "true"
    log_path = "/tmp/light-gdb.log"
  end
  if GdbConfig.log == "true" then
    local log_path = "/home/msun/nvim-gdb.log"
    local log_file = io.open(log_path, "a+")
    io.output(log_file)
    io.write("\nnvim-gdb starting! ------------------ \n")
  end
end
return log
