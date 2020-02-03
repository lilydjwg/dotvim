" Test recursive mapping of simple collections.

let s:expr = 'toupper(v:val)'

call vimtest#StartTap()
call vimtap#Plan(8)

let s:data = ['a', 'b', 'c']
call vimtap#Is(ingo#collections#recursive#map(s:data, s:expr), ['A', 'B', 'C'], 'in-place toupper of simple List')
call vimtap#Is(s:data, ['A', 'B', 'C'], 'in-place toupper modifies original')

let s:data = ['a', 'b', 'c']
call vimtap#Is(ingo#collections#recursive#MapWithCopy(s:data, s:expr), ['A', 'B', 'C'], 'copied toupper of simple List')
call vimtap#Is(s:data, ['a', 'b', 'c'], 'copied toupper keeps original')

let s:data = {'a': 'x', 'b': 'y'}
call vimtap#Is(ingo#collections#recursive#map(s:data, s:expr), {'a': 'X', 'b': 'Y'}, 'in-place toupper of simple Dict')
call vimtap#Is(s:data, {'a': 'X', 'b': 'Y'}, 'in-place toupper modifies original')

let s:data = {'a': 'x', 'b': 'y'}
call vimtap#Is(ingo#collections#recursive#MapWithCopy(s:data, s:expr), {'a': 'X', 'b': 'Y'}, 'copied toupper of simple Dict')
call vimtap#Is(s:data, {'a': 'x', 'b': 'y'}, 'copied toupper keeps original')

call vimtest#Quit()
