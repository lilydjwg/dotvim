" Test parsing a prepended register in arguments.

call vimtest#StartTap()
call vimtap#Plan(15)

call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister(''), ['', ''], 'parse empty arguments')
call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('text'), ['text', ''], 'parse only text')
call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('text a'), ['text', 'a'], 'parse text space register')
call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('a'), ['a', ''], 'parse single letter as text')
call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('text %'), ['text %', ''], 'parse readonly register belonging to text')

call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('text/'), ['text/', ''], 'parse text default sep')
call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('/a'), ['/', 'a'], 'parse default sep register')
call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('text/a'), ['text/', 'a'], 'parse text default sep register')

call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('textX', 'X'), ['textX', ''], 'parse text custom sep')
call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('Xa', 'X'), ['X', 'a'], 'parse custom sep register')
call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('textXa', 'X'), ['textX', 'a'], 'parse text custom sep register')

call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('a', 'X', 1), ['a', ''], 'parsing single letter with custom seps as text')
call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('a', [], 1), ['a', ''], 'parsing single letter with default seps as text')
call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('a', 'X', 0), ['', 'a'], 'force parsing single letter with custom seps as register')
call vimtap#Is(ingo#cmdargs#register#ParseAppendedWritableRegister('a', [], 0), ['', 'a'], 'force parsing single letter with default seps as register')

call vimtest#Quit()
