" Test parsing of position atoms.

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(substitute('foobar', ingo#regexp#parse#PositionAtomExpr(), '', 'g'), 'foobar', 'no position atoms')
call vimtap#Is(substitute('^', ingo#regexp#parse#PositionAtomExpr(), '', 'g'), '', '^')
call vimtap#Is(substitute('\%^foo\%$', ingo#regexp#parse#PositionAtomExpr(), '', 'g'), 'foo', '\%^ and \%$')
call vimtap#Is(substitute('\%#foo', ingo#regexp#parse#PositionAtomExpr(), '', 'g'), 'foo', '\%#')
call vimtap#Is(substitute('foo\%>42lbar', ingo#regexp#parse#PositionAtomExpr(), '', 'g'), 'foobar', '\%>l')

call vimtest#Quit()
