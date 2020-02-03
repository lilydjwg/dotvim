" Test matching any pattern.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#matches#Any('foobar', []), 1, 'matches no patterns')
call vimtap#Is(ingo#matches#Any('foobar', ['xy']), 0, 'does not match only pattern xy')
call vimtap#Is(ingo#matches#Any('foobar', ['o\+']), 1, 'matches only pattern o\+')
call vimtap#Is(ingo#matches#Any('foobar', ['o\+', 'xy', '^.\{6}$']), 1, 'matches first pattern o\+')
call vimtap#Is(ingo#matches#Any('foobar', ['xy', 'o\+', '^.\{6}$']), 1, 'matches second pattern o\+')
call vimtap#Is(ingo#matches#Any('foobar', ['xy', 'X\+', '^.\{6}$']), 1, 'matches last pattern ^.\{6}$')

call vimtest#Quit()
