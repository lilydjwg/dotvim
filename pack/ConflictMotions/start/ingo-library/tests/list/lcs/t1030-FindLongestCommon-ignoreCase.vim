" Test find longest common substrings case-insensitive.

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['Foobar', 'fooxy', 'FOObitch'], 1, 1),
\   'Foo',
\   'one common at front, first capitalization'
\)
call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['myFOO', 'theFoo', 'theyfoo'], 1, 1),
\   'FOO',
\   'one common at end, first capitalization'
\)
call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['myFoObar', 'thefOoxy', 'theyfOObitch'], 1, 1),
\   'FoO',
\   'one common in middle, first capitalization'
\)

call vimtap#Is(ingo#list#lcs#FindLongestCommon(
\   ['myfoobar', 'thefooxy', 'theyfoobitch']),
\   'foo',
\   'one common same capitalization in middle'
\)

call vimtest#Quit()
