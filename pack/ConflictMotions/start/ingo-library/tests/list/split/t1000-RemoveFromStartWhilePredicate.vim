" Test split off elements from the start with predicate.

call vimtest#StartTap()
call vimtap#Plan(14)

let g:list = [] | call vimtap#Is(ingo#list#split#RemoveFromStartWhilePredicate(g:list, '0'), [], 'nothing removed from empty list') | call vimtap#Is(g:list, [], 'unchanged source list')
let g:list = [] | call vimtap#Is(ingo#list#split#RemoveFromStartWhilePredicate(g:list, '1'), [], 'nothing removed from empty list') | call vimtap#Is(g:list, [], 'unchanged source list')

let g:list = [1, 2, 3] | call vimtap#Is(ingo#list#split#RemoveFromStartWhilePredicate(g:list, '0'), [], 'nothing removed from list') | call vimtap#Is(g:list, [1, 2, 3], 'unchanged source list')
let g:list = [1, 2, 3] | call vimtap#Is(ingo#list#split#RemoveFromStartWhilePredicate(g:list, '1'), [1, 2, 3], 'everything removed from list') | call vimtap#Is(g:list, [], 'emptied source list')

let g:list = [1, 2, 3] | call vimtap#Is(ingo#list#split#RemoveFromStartWhilePredicate(g:list, 'v:val <= 2'), [1, 2], 'two elements removed from list with expression') | call vimtap#Is(g:list, [3], 'last element left in source list')
function! MyPredicate( value )
    return (a:value <= 2)
endfunction
let g:list = [1, 2, 3] | call vimtap#Is(ingo#list#split#RemoveFromStartWhilePredicate(g:list, function('MyPredicate')), [1, 2], 'two elements removed from list with Funcref') | call vimtap#Is(g:list, [3], 'last element left in source list')

let g:list = [1, 2, 2, 3, 2, 1] | call vimtap#Is(ingo#list#split#RemoveFromStartWhilePredicate(g:list, 'v:val <= 2'), [1, 2, 2], 'three elements removed from list with expression, later matches are ignored') | call vimtap#Is(g:list, [3, 2, 1], 'elements left in source list')

call vimtest#Quit()
