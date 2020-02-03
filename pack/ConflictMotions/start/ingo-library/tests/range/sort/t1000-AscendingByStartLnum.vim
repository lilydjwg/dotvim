" Test sorting of ranges.

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#range#sort#AscendingByStartLnum([]), [], 'sorting empty List')
call vimtap#Is(ingo#range#sort#AscendingByStartLnum([[3, 3], [2, 7]]), [[2, 7], [3, 3]], 'sorting two ranges')
call vimtap#Is(ingo#range#sort#AscendingByStartLnum([[2, 7], [2, 1]]), [[2, 7], [2, 1]], 'sorting just considers start line number, not end')
call vimtap#Is(ingo#range#sort#AscendingByStartLnum([[2, 18], [3, 3], [2, 7]]), [[2, 18], [2, 7], [3, 3]], 'sorting three ranges')

call vimtest#Quit()
