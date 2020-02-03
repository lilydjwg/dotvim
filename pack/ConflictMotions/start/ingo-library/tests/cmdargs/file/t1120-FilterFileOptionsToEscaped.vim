" Test stripping file options and commands with joining and escaping.

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#Is(ingo#cmdargs#file#FilterFileOptionsToEscaped(['++enc=utf-8', '++ff=unix', 'bar']), [['bar'], '++enc=utf-8 ++ff=unix'], 'two options, and file')

call vimtest#Quit()
