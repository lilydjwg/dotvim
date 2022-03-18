" Test parsing a prepended register in arguments.

call vimtest#StartTap()
call vimtap#Plan(15)

call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister(''), ['', ''], 'parse empty arguments')
call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('text'), ['', 'text'], 'parse only text')
call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('a text'), ['a', 'text'], 'parse register space text')
call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('a'), ['', 'a'], 'parse single letter as text')
call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('% text'), ['', '% text'], 'parse readonly register belonging to text')

call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('/text'), ['', '/text'], 'parse default sep text')
call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('a/'), ['a', '/'], 'parse register default sep')
call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('a/text'), ['a', '/text'], 'parse register default sep text')

call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('Xtext', 'X'), ['', 'Xtext'], 'parse custom sep text')
call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('aX', 'X'), ['a', 'X'], 'parse register custom sep')
call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('aXtext', 'X'), ['a', 'Xtext'], 'parse register custom sep text')

call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('a', 'X', 1), ['', 'a'], 'parsing single letter with custom seps as text')
call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('a', [], 1), ['', 'a'], 'parsing single letter with default seps as text')
call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('a', 'X', 0), ['a', ''], 'force parsing single letter with custom seps as register')
call vimtap#Is(ingo#cmdargs#register#ParsePrependedWritableRegister('a', [], 0), ['a', ''], 'force parsing single letter with default seps as register')

call vimtest#Quit()
