" Test find all common substrings.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['foobar', 'fooxy', 'foobitch']),
\   [[[], ['bar', 'xy', 'bitch']], ['foo']],
\   'one common at front'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myfoo', 'thefoo', 'theyfoo']),
\   [[['my', 'the', 'they'], []], ['foo']],
\   'one common at end'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myfoobar', 'thefooxy', 'theyfoobitch']),
\   [[['my', 'the', 'they'], ['bar', 'xy', 'bitch']], ['foo']],
\   'one common in middle'
\)

call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['metfooforbarby', 'havefootobasil', 'gotfooinbasin']),
\   [[['met', 'have', 'got'], ['for', 'to', 'in'], ['rby', 'sil', 'sin']], ['foo', 'ba']],
\   'longer common before shorter'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['barbygetfoofor', 'basilgivefooto', 'basingotfooin']),
\   [[[], ['rby', 'sil', 'sin'], ['et', 'ive', 'ot'], ['for', 'to', 'in']], ['ba', 'g', 'foo']],
\   'longer common after shorter'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['basbygetfoofor', 'basilgivefooto', 'basingotfooin']),
\   [[[], ['by', 'il', 'in'], ['et', 'ive', 'ot'], ['for', 'to', 'in']], ['bas', 'g', 'foo']],
\   'same length common prefers first'
\)

call vimtest#Quit()
