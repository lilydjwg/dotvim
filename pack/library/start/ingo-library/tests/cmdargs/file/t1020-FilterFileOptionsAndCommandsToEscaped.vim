" Test stripping file options and commands with joining and escaping.

call vimtest#StartTap()
call vimtap#Plan(2)

call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommandsToEscaped(['++ff=unix', '+setl et|  echomsg "foobar"', 'bar']), [['bar'], '++ff=unix +setl\ et|\ \ echomsg\ "foobar"'], 'option, command, and file')
call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsAndCommandsToEscaped(["+echomsg 'foo with \\% and # and \\\\<this>'", 'bar']), [['bar'], "+echomsg\\ 'foo\\ with\\ %\\ and\\ #\\ and\\ \\\\<this>'"], 'command with cmdline-special escaping variants and file')

call vimtest#Quit()
