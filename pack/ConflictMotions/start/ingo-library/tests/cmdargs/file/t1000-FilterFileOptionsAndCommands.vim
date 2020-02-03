" Test stripping file options and commands.

call vimtest#StartTap()
call vimtap#Plan(14)

call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands([]), [[], []], 'empty fileglobs')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['/tmp/foo']), [['/tmp/foo'], []], 'just a file')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['foo*', 'bar']), [['foo*', 'bar'], []], 'just two files')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['+setl et', 'foo*', 'bar']), [['foo*', 'bar'], ['+setl et']], 'command and two files')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['foo*', '+setl et']), [['foo*', '+setl et'], []], 'command after fileglob is treated as fileglob')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['foo*', '++ff=unix']), [['foo*', '++ff=unix'], []], 'option after fileglob is treated as fileglob')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['+setf txt', '+setl et', 'foo']), [['+setl et', 'foo'], ['+setf txt']], 'second command is treated as fileglob')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['++ff=unix', 'foo*', 'bar']), [['foo*', 'bar'], ['++ff=unix']], 'option and two files')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['++ff=unix', '++enc=utf-8', 'foo*', 'bar']), [['foo*', 'bar'], ['++ff=unix', '++enc=utf-8']], 'two options and two files')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['++ff=unix', '++enc=utf-8', '+setl et', 'foo*', 'bar']), [['foo*', 'bar'], ['++ff=unix', '++enc=utf-8', '+setl et']], 'two options, command, and two files')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['++ff=unix', '++enc=utf-8', '+setl et']), [[], ['++ff=unix', '++enc=utf-8', '+setl et']], 'two options, one command')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['++ff=unix', '+setl et', '++enc=utf-8', 'foo*', 'bar']), [['++enc=utf-8', 'foo*', 'bar'], ['++ff=unix', '+setl et']], 'option after command is treated as fileglob')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['+setl et', '++ff=unix', '++enc=utf-8', 'foo*', 'bar']), [['++ff=unix', '++enc=utf-8', 'foo*', 'bar'], ['+setl et']], 'options after command are treated as fileglob')

call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(['++whatis=that', 'foo*', 'bar']), [['++whatis=that', 'foo*', 'bar'], []], 'invalid option is treated as fileglob')

call vimtest#Quit()
