
gdb -i=mi -quiet -iex "set pagination off" -iex "set mi-async on" -tty /dev/pts/4
server new-ui mi /dev/pts/3

sign_define('sign_name', {'text': '◌ ', 'texthl' : '', 'linehl' : ''})
sign_place(0, 'group_name', 'sign_name', bufnr, {'lnum': lnum})

lua require('breakpoint').define_sign(nil,'doc.md', 14)
lua require('breakpoint').place(nil,'doc.md', 14)

echo sign_getdefined()
echo sign_getplaced(1)
