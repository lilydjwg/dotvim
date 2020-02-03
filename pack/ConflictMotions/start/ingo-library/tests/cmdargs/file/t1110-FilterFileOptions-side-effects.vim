" Test modification of the passed-in fileglobs List when stripping options.

call vimtest#StartTap()
call vimtap#Plan(2)

let g:fileglobs = ['++ff=unix', '++enc=utf-8', 'foo*', 'bar']
call vimtap#Is(ingo#cmdargs#file#FilterFileOptions(g:fileglobs), [['foo*', 'bar'], ['++ff=unix', '++enc=utf-8']], 'two options and two files')
call vimtap#Is(g:fileglobs, ['foo*', 'bar'], 'original argument list has been reduced')

call vimtest#Quit()
