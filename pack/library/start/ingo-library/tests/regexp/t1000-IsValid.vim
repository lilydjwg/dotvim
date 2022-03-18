" Test testing regular expression for correctness.

call vimtest#StartTap()
call vimtap#Plan(8)

call vimtap#Is(ingo#regexp#IsValid(''), 1, 'empty pattern is valid')
call vimtap#Is(ingo#regexp#IsValid('foo'), 1, 'literal pattern is valid')
call vimtap#Is(ingo#regexp#IsValid('^[fF]o\+$'), 1, 'simple pattern is valid')

call vimtap#Is(ingo#regexp#IsValid('fo**'), 0, 'fo** is invalid')
call vimtap#Like(ingo#err#Get(), '^E871:', "fo** gives E871: (NFA regexp) Can't have a multi follow a multi")

call ingo#err#Clear()
call vimtap#Is(ingo#regexp#IsValid('foo\(bar', 'custom'), 0, 'foo\(bar is invalid')
call vimtap#Is(ingo#err#Get(), '', 'custom error context keeps default context')
call vimtap#Like(ingo#err#Get('custom'), '^E54:', "fo** gives E54: Unmatched \(")

call vimtest#Quit()
