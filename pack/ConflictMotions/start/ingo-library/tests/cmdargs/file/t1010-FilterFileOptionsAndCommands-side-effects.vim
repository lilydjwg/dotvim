" Test modification of the passed-in fileglobs List when stripping options and commands.

call vimtest#StartTap()
call vimtap#Plan(2)

let g:fileglobs = ['++ff=unix', '++enc=utf-8', '+setl et', 'foo*', 'bar']
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommands(g:fileglobs), [['foo*', 'bar'], ['++ff=unix', '++enc=utf-8', '+setl et']], 'two options, command, and two files')
call vimtap#Is(g:fileglobs, ['foo*', 'bar'], 'original argument list has been reduced')

call vimtest#Quit()
