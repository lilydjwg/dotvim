" Test merging of line numbers.

call vimtest#StartTap()
call vimtap#Plan(2)

let s:source = [1, 2, 3, 6, 8, 9, 10, 10, 11, 19, 18, 20, 15, 16, 20, 21, 22, 24, 23, 25]
let s:expected = [[1, 3], [6, 6], [8, 11], [15, 16], [18, 25]]

call vimtap#Is(ingo#range#merge#FromLnums(s:source), s:expected, 'merge of List of line numbers')
call vimtap#Is(ingo#range#merge#FromLnums(ingo#collections#ToDict(s:source)), s:expected, 'merge of Dict of line numbers')

call vimtest#Quit()
