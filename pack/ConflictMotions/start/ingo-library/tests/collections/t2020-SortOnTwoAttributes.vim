" Test sorting dicts based on two attributes.

function! s:SortOnFooThenBar( o1, o2 )
    return ingo#collections#SortOnTwoAttributes('foo', 'bar', a:o1, a:o2)
endfunction
function! s:SortWithDefault( o1, o2 )
    return ingo#collections#SortOnTwoAttributes('foo', 'bar', a:o1, a:o2, 99)
endfunction
function! s:SortWithDefaults( o1, o2 )
    return ingo#collections#SortOnTwoAttributes('foo', 'bar', a:o1, a:o2, 99, 'zzz')
endfunction

let s:one   = {          'bar': 'first'}
let s:two   = {'foo': 2                }
let s:three = {          'bar': 'third'}
let s:four  = {'foo': 4, 'bar': 'fourth'}
let s:five  = {'foo': 4, 'bar': 'fifth'}
let s:objects = [s:four, s:two, s:five, s:three, s:five, s:one]

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(sort(copy(s:objects), 's:SortOnFooThenBar'), [s:one, s:three, s:two, s:five, s:five, s:four], 'sorted based on foo then bar attributes')
call vimtap#Is(sort(copy(s:objects), 's:SortWithDefault'),  [s:two, s:five, s:five, s:four, s:one, s:three], 'sorted based on foo (default 99) then bar (same default) attributes')
let s:twoBe = {'foo': 2, 'bar': 'exists'}
call vimtap#Is(sort([s:four, s:two, s:three, s:twoBe, s:one], 's:SortWithDefaults'),  [s:twoBe, s:two, s:four, s:one, s:three], 'sorted based on foo (default 99) then bar (default zzz) attributes')

call vimtest#Quit()
