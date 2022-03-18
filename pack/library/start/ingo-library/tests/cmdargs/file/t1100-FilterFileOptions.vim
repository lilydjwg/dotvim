" Test stripping file options.

call vimtest#StartTap()
call vimtap#Plan(8)

call vimtap#Is(ingo#cmdargs#file#FilterFileOptions([]), [[], []], 'empty fileglobs')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptions(['/tmp/foo']), [['/tmp/foo'], []], 'just a file')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptions(['foo*', 'bar']), [['foo*', 'bar'], []], 'just two files')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptions(['+setl et', 'foo*', 'bar']), [['+setl et', 'foo*', 'bar'], []], 'command is treated as file')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptions(['foo*', '++ff=unix']), [['foo*', '++ff=unix'], []], 'option after fileglob is treated as fileglob')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptions(['++ff=unix', 'foo*', 'bar']), [['foo*', 'bar'], ['++ff=unix']], 'option and two files')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptions(['++ff=unix', '++enc=utf-8', 'foo*', 'bar']), [['foo*', 'bar'], ['++ff=unix', '++enc=utf-8']], 'two options and two files')

call vimtap#Is(ingo#cmdargs#file#FilterFileOptions(['++whatis=that', 'foo*', 'bar']), [['++whatis=that', 'foo*', 'bar'], []], 'invalid option is treated as fileglob')

call vimtest#Quit()
