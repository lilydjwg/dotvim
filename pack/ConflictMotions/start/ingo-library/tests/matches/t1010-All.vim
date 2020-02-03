" Test matching all patterns.

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(ingo#matches#All('foobar', []), 1, 'matches no patterns')
call vimtap#Is(ingo#matches#All('foobar', ['xy']), 0, 'does not match only pattern xy')
call vimtap#Is(ingo#matches#All('foobar', ['o\+']), 1, 'matches only pattern o\+')
call vimtap#Is(ingo#matches#All('foobar', ['o\+', 'xy', '^.\{6}$']), 0, 'does not match second pattern')
call vimtap#Is(ingo#matches#All('foobar', ['^[fF]', 'o\+', '^.\{6}$']), 1, 'matches all three patterns')

call vimtest#Quit()
