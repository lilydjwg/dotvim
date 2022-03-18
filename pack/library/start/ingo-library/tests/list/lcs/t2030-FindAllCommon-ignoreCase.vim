" Test find all common substrings case-insensitive.

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['Foobar', 'fooxy', 'FOObitch'], 1, 0, 1),
\   [[[], ['bar', 'xy', 'bitch']], ['Foo']],
\   'one common at front, first capitalization'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myFOO', 'theFoo', 'theyfoo'], 1, 0, 1),
\   [[['my', 'the', 'they'], []], ['FOO']],
\   'one common at end, first capitalization'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myFoObar', 'thefOoxy', 'theyfOObitch'], 1, 0, 1),
\   [[['my', 'the', 'they'], ['bar', 'xy', 'bitch']], ['FoO']],
\   'one common in middle, first capitalization'
\)

call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['foobar', 'fooxy', 'foobitch'], 1, 0, 1),
\   [[[], ['bar', 'xy', 'bitch']], ['foo']],
\   'one common same capitalization at front'
\)

call vimtest#Quit()
