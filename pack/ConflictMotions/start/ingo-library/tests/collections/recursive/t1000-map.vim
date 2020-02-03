" Test recursive mapping.

let s:expr = 'toupper(v:val)'
function! s:CreateData()
    return ['a', 'b', [{'foo': 'bar', 'rec': ['e', 'ff']}, 'd']]
endfunction

call vimtest#StartTap()
call vimtap#Plan(4)

let s:data = s:CreateData()
call vimtap#Is(ingo#collections#recursive#map(s:data, s:expr), ['A', 'B', [{'foo': 'BAR', 'rec': ['E', 'FF']}, 'D']], 'in-place toupper')
call vimtap#Is(s:data, ['A', 'B', [{'foo': 'BAR', 'rec': ['E', 'FF']}, 'D']], 'in-place toupper modifies original')

let s:data = s:CreateData()
call vimtap#Is(ingo#collections#recursive#MapWithCopy(s:data, s:expr), ['A', 'B', [{'foo': 'BAR', 'rec': ['E', 'FF']}, 'D']], 'copied toupper')
call vimtap#Is(s:data, ['a', 'b', [{'foo': 'bar', 'rec': ['e', 'ff']}, 'd']], 'copied toupper keeps original')

call vimtest#Quit()
