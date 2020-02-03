" Test FirstMatchIndex.

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(ingo#list#pattern#FirstMatchIndex(['foo', 'fox', 'fozzy'], 'o[^o]'), 1, 'return first of two matching indices')
call vimtap#Is(ingo#list#pattern#FirstMatchIndex(['foo', 'fox', 'fozzy'], 'noMatch'), -1, 'no matches return -1')
call vimtap#Is(ingo#list#pattern#FirstMatchIndex([], '^'), -1, 'empty list with matching pattern returns -1')

call vimtest#Quit()
