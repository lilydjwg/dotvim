" Test FirstMatch.

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(ingo#list#pattern#FirstMatch(['foo', 'fox', 'fozzy'], 'o[^o]'), 'fox', 'return first of two matches')
call vimtap#Is(ingo#list#pattern#FirstMatch(['foo', 'fox', 'fozzy'], 'noMatch'), '', 'no matches return empty String')
call vimtap#Is(ingo#list#pattern#FirstMatch(['foo', 'fox', 'fozzy'], 'noMatch', 42), 42, 'no matches return custom noMatchValue')

call vimtest#Quit()
