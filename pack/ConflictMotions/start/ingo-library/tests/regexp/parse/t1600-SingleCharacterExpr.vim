" Test parsing of single characters.

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(substitute('foobar', ingo#regexp#parse#SingleCharacterExpr(), '', 'g'), 'foobar', 'no single character match atom')
call vimtap#Is(substitute('f..bar', ingo#regexp#parse#SingleCharacterExpr(), '', 'g'), 'fbar', '..')
call vimtap#Is(substitute('foo\.\_.b.a.r.', ingo#regexp#parse#SingleCharacterExpr(), '', 'g'), 'foo\.bar', '..')

call vimtest#Quit()
