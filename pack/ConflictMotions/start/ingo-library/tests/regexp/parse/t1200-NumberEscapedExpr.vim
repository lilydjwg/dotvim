" Test parsing of number escapes.

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(substitute('foobar', ingo#regexp#parse#NumberEscapesExpr(), '', 'g'), 'foobar', 'no number escapes')
call vimtap#Is(substitute('foo\%d34bar', ingo#regexp#parse#NumberEscapesExpr(), '', 'g'), 'foobar', '\%d')
call vimtap#Is(substitute('foo\%xFFbar', ingo#regexp#parse#NumberEscapesExpr(), '', 'g'), 'foobar', '\%x')
call vimtap#Is(substitute('foo\%u03eabar', ingo#regexp#parse#NumberEscapesExpr(), '', 'g'), 'foobar', '\%u')
call vimtap#Is(substitute('foo\%U', ingo#regexp#parse#NumberEscapesExpr(), '', 'g'), 'foo\%U', 'too short \%U')

call vimtest#Quit()
