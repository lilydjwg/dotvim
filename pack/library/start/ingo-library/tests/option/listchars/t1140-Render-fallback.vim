" Test rendering with fallback.

set listchars=eol:$

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", 1, {'listchars': {'eol': '^J'}, 'fallback': {'tab': '^I'}}), '^I^I  some text^I^J', 'text rendered at end')

call vimtest#Quit()
