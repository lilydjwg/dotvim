" Test find longest common substrings with a mimimum length.

call vimtest#StartTap()
call vimtap#Plan(2)

call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['myfoobar', 'thefooxy', 'theyfoobitch'], 3),
\   'foo',
\   'minimumLength reached'
\)
call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['myfoobar', 'thefooxy', 'theyfoobitch'], 4),
\   '',
\   'minimumLength missed'
\)

call vimtest#Quit()
