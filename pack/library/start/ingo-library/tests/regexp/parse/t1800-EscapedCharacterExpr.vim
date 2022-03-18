" Test parsing of escaped characters.

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(substitute('foobar', ingo#regexp#parse#EscapedCharacterExpr(), '', 'g'), 'foobar', 'no other atoms')
call vimtap#Is(substitute('foo\nbar', ingo#regexp#parse#EscapedCharacterExpr(), '', 'g'), 'foobar', '\n')
call vimtap#Is(substitute('\\n\e\t\r\b\\\n\\t', ingo#regexp#parse#EscapedCharacterExpr(), '', 'g'), '\\n\\\\t', 'both escaped and non-escaped')

call vimtest#Quit()
