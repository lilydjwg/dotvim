" Test AllItemsMatch.

call vimtest#StartTap()
call vimtap#Plan(8)

call vimtap#Is(ingo#list#pattern#AllItemsMatch(['x'], 'x'), 1, 'single element is exact')
call vimtap#Is(ingo#list#pattern#AllItemsMatch(['x'], 'Y'), 0, 'single element is different')

call vimtap#Is(ingo#list#pattern#AllItemsMatch([1, 2, 3], '^.$'), 1, 'small digits are all single character')
call vimtap#Is(ingo#list#pattern#AllItemsMatch([1, 22, 3], '^.$'), 0, 'digits are not all single character')
call vimtap#Is(ingo#list#pattern#AllItemsMatch([11, 22, 33], '^.$'), 0, 'no digits are single character')

call vimtap#Is(ingo#list#pattern#AllItemsMatch(['foo', 'fox', 'fozzy'], 'fo'), 1, 'all contain fo')
call vimtap#Is(ingo#list#pattern#AllItemsMatch(['foo', 'fox', 'fozzy'], '\(.\)\1'), 0, 'all contain doubled character')

call vimtap#Is(ingo#list#pattern#AllItemsMatch([], '^.$'), 1, 'empty list')

call vimtest#Quit()
