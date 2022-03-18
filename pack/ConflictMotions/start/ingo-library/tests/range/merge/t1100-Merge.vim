" Test merging of ranges.

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#Is(ingo#range#merge#Merge([[1, 3], [6, 6], [8, 10], [10, 11], [18, 20], [15, 16], [20, 25]]), [[1, 3], [6, 6], [8, 11], [15, 16], [18, 25]], 'merge of ranges')

call vimtest#Quit()
