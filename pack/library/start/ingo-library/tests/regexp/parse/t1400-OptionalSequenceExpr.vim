" Test parsing of optional sequences.

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(substitute('foo\%[bar]quux', ingo#regexp#parse#OptionalSequenceExpr(), '', 'g'), 'fooquux', 'optional sequence')
call vimtap#Is(substitute('r\%[[eo]ad]', ingo#regexp#parse#OptionalSequenceExpr(), '', 'g'), 'r', 'optional sequence with character class inside')
call vimtap#Is(substitute('index\%[[[]0[]]]', ingo#regexp#parse#OptionalSequenceExpr(), '', 'g'), 'index', 'optional sequence with square brackets')

call vimtest#Quit()
