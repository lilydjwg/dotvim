" Test joining and escaping of file options and commands has no side effect.

call vimtest#StartTap()
call vimtap#Plan(2)

let s:fileglobs = ['++nobin', 'setl et | echomsg "foobar"|set wrap']
let s:originalFileGlobs = copy(s:fileglobs)
call vimtap#Is(ingo#cmdargs#file#FileOptionsAndCommandsToEscapedExCommandLine(s:fileglobs), '++nobin setl\ et\ |\ echomsg\ "foobar"|set\ wrap', 'one option one command')
call vimtap#Is(s:fileglobs, s:originalFileGlobs, 'original fileglobs are not modified')

call vimtest#Quit()
