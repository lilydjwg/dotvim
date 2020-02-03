" Test removal of leading and trailing pattern.

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(ingo#str#TrimPattern('', '[xX]\+'), '', 'no-op on empty string')
call vimtap#Is(ingo#str#TrimPattern('fox bar', '[xX]\+'), 'fox bar', 'no surrounding matches, inner kept intact')
call vimtap#Is(ingo#str#TrimPattern('xXxXfox barXx', '[xX]\+'), 'fox bar', 'remove surrounding matches')

call vimtap#Is(ingo#str#TrimPattern('xXxXfox barXxX', 'x\+', 'X\+'), 'XxXfox barXx', 'use different patterns for leading and trailing matches')
call vimtap#Is(ingo#str#TrimPattern('xXxXfox barXx', '[uU]\+', '[xX]\+'), 'xXxXfox bar', 'only trailing pattern matches')

call vimtest#Quit()
