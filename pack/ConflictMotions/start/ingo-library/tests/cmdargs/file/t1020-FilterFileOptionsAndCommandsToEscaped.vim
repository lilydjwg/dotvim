" Test stripping file options and commands with joining and escaping.

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommandsToEscaped(['++ff=unix', '+setl et|  echomsg "foobar"', 'bar']), [['bar'], '++ff=unix +setl\ et|\ \ echomsg\ "foobar"'], 'option, command, and file')

call vimtest#Quit()
