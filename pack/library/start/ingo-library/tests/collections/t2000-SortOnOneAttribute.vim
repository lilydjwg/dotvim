" Test sorting dicts based on one attribute.

function! s:SortOnFoo( o1, o2 )
    return ingo#collections#SortOnOneAttribute('foo', a:o1, a:o2)
endfunction
function! s:SortOnBar( o1, o2 )
    return ingo#collections#SortOnOneAttribute('bar', a:o1, a:o2)
endfunction
function! s:SortOnBarWithDefault( o1, o2 )
    return ingo#collections#SortOnOneAttribute('bar', a:o1, a:o2, 'z')
endfunction

let s:one   = {'foo': 1, 'bar': 'first'}
let s:two   = {'foo': 2}
let s:three = {'foo': 3, 'bar': 'third'}
let s:objects = [s:two, s:three, s:one]

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(sort(copy(s:objects), 's:SortOnFoo'), [s:one, s:two, s:three], 'sorted based on foo attribute')
call vimtap#Is(sort(copy(s:objects), 's:SortOnBar'), [s:two, s:one, s:three], 'sorted based on (partially missing) bar attribute')
call vimtap#Is(sort(copy(s:objects), 's:SortOnBarWithDefault'), [s:one, s:three, s:two], 'sorted based on (partially missing) bar attribute with default z')

call vimtest#Quit()
