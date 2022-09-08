## gdb mi commands.
gdb -i=mi -quiet -iex "set pagination off" -iex "set mi-async on" -tty /dev/pts/4
server new-ui mi /dev/pts/3


## Create and place a sign.
sign_define('sign_name', {'text': '◌ ', 'texthl' : '', 'linehl' : ''})
sign_place(0, 'group_name', 'sign_name', bufnr, {'lnum': lnum})

lua require('breakpoint').define_sign(nil,'doc.md', 14)
lua require('breakpoint').place(nil,'doc.md', 14)

echo sign_getdefined()
echo sign_getplaced(1)



## Make a line highlight.
func s:Highlight(init, old, new)
  let default = a:init ? 'default ' : ''
  if a:new ==# 'light' && a:old !=# 'light'
    exe "hi " . default . "debugPC term=reverse ctermbg=lightblue guibg=lightblue"
  elseif a:new ==# 'dark' && a:old !=# 'dark'
    exe "hi " . default . "debugPC term=reverse ctermbg=darkblue guibg=darkblue"
  endif
endfunc
call s:Highlight(1, '', &background)
call sign_define('debugPC', #{linehl: 'debugPC'})







## Others about lua job and channel.
--[[
  local channel_id = vim.api.nvim_open_term(gdb_bufnr, {
    on_input = function(_, _, _, data)
      pcall(vim.api.nvim_chan_send, shell_job, data)
    end,
  })

  shell_job = vim.fn.jobstart({"/usr/bin/bash"}, {
    pty = true,
    on_stdout = function (_, msg, _)
      vim.api.nvim_chan_send(channel_id, msg[1])
      for _, line in pairs(msg) do
        vim.api.nvim_chan_send(channel_id, line)
      end
-- table.concat
      for _, line in pairs(msg) do
        vim.api.nvim_chan_send(channel_id, line)
        --vim.fn.appendbufline(gdb_bufnr, vim.fn.line("$", gdb_win_id), line)
      end
    end,
    on_stderr = function (_, _, _)
      for _, line in pairs(msg) do
        vim.fn.appendbufline(gdb_bufnr, vim.fn.line("$", gdb_win_id) - 1, line)
      end
    end,
    on_exit = function (_, _, _)
    end,
  })
  vim.api.nvim_chan_send(channel_id, "\ra")

  vim.bo.buftype = "prompt"
  vim.fn.prompt_setcallback(gdb_bufnr, function(text)
    io.write("entered: " .. text .. " \n")
    local res = vim.fn.chansend(shell_job, {text, ""})
    io.write("result: " .. res .. "\n")
  end)
  vim.fn.prompt_setprompt(gdb_bufnr, "")

  local output_win_id, output_bufnr = window.vertical_layout(window, 20, "left", {
    list = false,
    relativenumber = false,
    number = false,
    winfixwidth = true,
    winfixheight = true,
    wrap = false,
    signcolumn = "auto"
  })
  prompt-buffer
  channel-functions-details

  " 建立通道日志，以记录发生的事件。
  call ch_logfile('logfile', 'w')

  " 处理键入文本行的函数。
  func TextEntered(text)
    " 给文本附加 Enter，发送到外壳。
    call ch_sendraw(g:shell_job, a:text .. "\n")
  endfunc

  " 处理外壳输出的函数: 附加到提示行之上。
  func GotOutput(channel, msg)
    call append(line("$") - 1, "- " .. a:msg)
  endfunc

  " 处理外壳退出的函数: 关闭窗口。
  func JobExit(job, status)
    quit!
  endfunc

  " 在后台启动外壳。
  let shell_job = job_start(["/bin/sh"], #{
    \ out_cb: function('GotOutput'),
    \ err_cb: function('GotOutput'),
    \ exit_cb: function('JobExit'),
    \ })

  new
  set buftype=prompt
  let buf = bufnr('')
  call prompt_setcallback(buf, function("TextEntered"))
  eval prompt_setprompt(buf, "shell command: ")

  " 开始接受外壳命令
  startinsert
--]]

--[[
  func TextEntered(text)
    call chansend(g:shell_job, [a:text, ''])
  endfunc

  func GotOutput(channel, msg, name)
    call append(line("$") - 1, a:msg)
  endfunc

  func JobExit(job, status, event)
    quit!
  endfunc

  let shell_job = jobstart(["/bin/sh"], #{
    \ on_stdout: function('GotOutput'),
    \ on_stderr: function('GotOutput'),
    \ on_exit: function('JobExit'),
    \ })

  new
  set buftype=prompt
  let buf = bufnr('')
  call prompt_setcallback(buf, function("TextEntered"))
  call prompt_setprompt(buf, "shell command: ")

  startinsert
--]]


--[[
--]]



