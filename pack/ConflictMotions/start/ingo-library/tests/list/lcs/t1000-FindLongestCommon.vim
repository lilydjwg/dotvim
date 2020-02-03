" Test find longest common substrings.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['foobar', 'fooxy', 'foobitch']),
\   'foo',
\   'one common at front'
\)
call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['myfoo', 'thefoo', 'theyfoo']),
\   'foo',
\   'one common at end'
\)
call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['myfoobar', 'thefooxy', 'theyfoobitch']),
\   'foo',
\   'one common in middle'
\)

call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['metfooforbarbi', 'havefootobasil', 'gotfooinbasin']),
\   'foo',
\   'longer common before shorter'
\)
call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['barbigetfoofor', 'basilgivefooto', 'basingotfooin']),
\   'foo',
\   'longer common after shorter'
\)
call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['basbigetfoofor', 'basilgivefooto', 'basingotfooin']),
\   'bas',
\   'same length common prefers first'
\)

call vimtest#Quit()
