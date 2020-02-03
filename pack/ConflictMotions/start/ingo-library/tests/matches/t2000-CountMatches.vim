" Test counting matches in text.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#matches#CountMatches('foobar', ''), 7, 'matches before / after every character with empty pattern')
call vimtap#Is(ingo#matches#CountMatches('', 'o\+'), 0, 'no matches with empty text')
call vimtap#Is(ingo#matches#CountMatches('our house is foobar', 'o\+'), 3, '3 occurrences of o\+ in String')
call vimtap#Is(ingo#matches#CountMatches(['our', 'house', 'is', 'foobar'], 'o\+'), 3, '3 occurrences of o\+ in List')
call vimtap#Is(ingo#matches#CountMatches('our house is foobar', '.*'), 1, '1 occurrence of .* with String')
call vimtap#Is(ingo#matches#CountMatches(['our', 'house', 'is', 'foobar', ''], '.*'), 5, '5 of .* in 5-element List')

call vimtest#Quit()
