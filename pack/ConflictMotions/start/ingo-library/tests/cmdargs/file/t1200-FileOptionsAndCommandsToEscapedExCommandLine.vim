" Test joining and escaping of file options and commands.

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(ingo#cmdargs#file#FileOptionsAndCommandsToEscapedExCommandLine(['++nobin', '++ff=dos']), '++nobin ++ff=dos', 'two options')
call vimtap#Is(ingo#cmdargs#file#FileOptionsAndCommandsToEscapedExCommandLine(['setl et | echomsg "foobar"|set wrap']), 'setl\ et\ |\ echomsg\ "foobar"|set\ wrap', 'one command')
call vimtap#Is(ingo#cmdargs#file#FileOptionsAndCommandsToEscapedExCommandLine(['++ff=unix', '++enc=utf-8', 'setl et | echomsg "foobar"|set wrap']), '++ff=unix ++enc=utf-8 setl\ et\ |\ echomsg\ "foobar"|set\ wrap', 'two options and one command')

call vimtest#Quit()
