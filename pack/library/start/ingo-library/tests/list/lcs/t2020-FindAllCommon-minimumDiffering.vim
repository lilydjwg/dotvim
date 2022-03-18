" Test find all common substrings with a minimum length of the differing parts.

call vimtest#StartTap()
call vimtap#Plan(14)

call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myfoobar','yourfoosball'], 1, 0),
\   [[['m', ''], ['', 'our'], ['', 's'], ['r', 'll']], ['y', 'foo', 'ba']],
\   'no minimumDifferingLength'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myfoobar','yourfoosball'], 1, 1),
\   [[['my', 'your'], ['bar', 'sball']], ['foo']],
\   'minimumDifferingLength filters empty'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myfoobarx','yourfoosballx'], 1, 1),
\   [[['my', 'your'], ['bar', 'sball'], []], ['foo', 'x']],
\   'minimumDifferingLength filters empty, common at end'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['Ilovefoobar','Imissfoosball'], 1, 1),
\   [[[], ['love', 'miss'], ['bar', 'sball']], ['I', 'foo']],
\   'minimumDifferingLength filters empty, common at begin'
\)

call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myFooInBar', 'theFooHasBar'], 1, 2),
\   [[['my', 'the'], ['In', 'Has'], []], ['Foo', 'Bar']],
\   'minimumDifferingLength exceeded'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myFooInBarX', 'theFooHasBarY'], 1, 3),
\   [[['myFooInBarX', 'theFooHasBarY']], []],
\   'minimumDifferingLength filters too short'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myFooInBar', 'theFooHasBar'], 1, 3),
\   [[['myFooIn', 'theFooHas'], []], ['Bar']],
\   'minimumDifferingLength filters prefix too short'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myFooxInBarForMe', 'theFooxHasBarCanDo'], 1, 3),
\   [[['myFooxIn', 'theFooxHas'], ['ForMe', 'CanDo']], ['Bar']],
\   'minimumDifferingLength filters prefix and middle too short'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['forMeFooxInBarMy', 'canDoFooxHasBarThe'], 1, 3),
\   [[['forMe', 'canDo'], ['InBarMy', 'HasBarThe']], ['Foox']],
\   'minimumDifferingLength filters middle and suffix too short'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myFooxForMeBarIn', 'theFooxCanDiBarHas'], 1, 3),
\   [[['myFooxForMeBarIn', 'theFooxCanDiBarHas']], []],
\   'minimumDifferingLength filters prefix and suffix too short'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['mineFooxInBarForMe', 'theFooxHasBarCanDo'], 1, 3),
\   [[['mineFooxIn', 'theFooxHas'], ['ForMe', 'CanDo']], ['Bar']],
\   'minimumDifferingLength filters middle too short'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['mineFooxInLongerForMe', 'theFooxHasLongerCanDo'], 1, 3),
\   [[['mineFooxIn', 'theFooxHas'], ['ForMe', 'CanDo']], ['Longer']],
\   'minimumDifferingLength filters middle too short'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['mineFooxGagLongerOl', 'ragFooxHasLongerNi'], 1, 3),
\   [[['mine', 'rag'], ['GagLongerOl', 'HasLongerNi']], ['Foox']],
\   'minimumDifferingLength filters suffix after later longest too short'
\)
call vimtap#Is(ingo#list#lcs#FindAllCommon(
\   ['myFooxForMeBarIn', 'theFooxCanDoBarHas'], 1, 3),
\   [[['myFooxF', 'theFooxCanD'], ['rMeBarIn', 'BarHas']], ['o']],
\   'minimumDifferingLength filters prefix and suffix too short but short alternative common'
\)

call vimtest#Quit()
