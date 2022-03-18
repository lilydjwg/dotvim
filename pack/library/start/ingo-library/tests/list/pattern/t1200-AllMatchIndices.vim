" Test AllMatchIndices.

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(ingo#list#pattern#AllMatchIndices(['foo', 'fox', 'fozzy'], 'o[^o]'), [1, 2], 'return two matching indices')
call vimtap#Is(ingo#list#pattern#AllMatchIndices(['foo', 'fox', 'fozzy'], 'noMatch'), [], 'no matches return empty List')
call vimtap#Is(ingo#list#pattern#AllMatchIndices([], '^'), [], 'empty list with matching pattern returns empty List')

call vimtest#Quit()
