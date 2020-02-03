" Test creating Dict from keys via extractor.

let s:count = 0
function! Counter( key ) abort
    let s:count += 1
    return s:count
endfunction
function! Duplicator( key ) abort
    return a:key . a:key
endfunction

call vimtest#StartTap()
call vimtap#Plan(2)

call vimtap#Is(ingo#dict#FromKeys(['foo', 'bar', 'baz'], function('Counter')), {'foo': 1, 'bar': 2, 'baz': 3}, 'create with values from counter')
call vimtap#Is(ingo#dict#FromKeys(['foo', 'bar', 'baz'], function('Duplicator')), {'foo': 'foofoo', 'bar': 'barbar', 'baz': 'bazbaz'}, 'create with values as duplicated keys')

call vimtest#Quit()
