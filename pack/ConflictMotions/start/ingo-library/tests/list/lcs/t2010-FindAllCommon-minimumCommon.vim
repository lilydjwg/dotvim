" Test find all common substrings with a minimum length.

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myfoobar', 'thefooxy', 'theyfoobitch'], 3),
\   [[['my', 'the', 'they'], ['bar', 'xy', 'bitch']], ['foo']],
\   'minimumCommonLength reached'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myfoobar', 'thefooxy', 'theyfoobitch'], 4),
\   [[['myfoobar', 'thefooxy', 'theyfoobitch']], []],
\   'minimumCommonLength missed'
\)

call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['metfooforbarby', 'havefootobasil', 'gotfooinbasin'], 3),
\   [[['met', 'have', 'got'], ['forbarby', 'tobasil', 'inbasin']], ['foo']],
\   'minimumCommonLength filters out shorter'
\)

call vimtest#Quit()
