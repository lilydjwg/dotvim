" Test creating Dict from values.

function! BothExtractor( val ) abort
    return a:val[0] . a:val[-1:-1]
endfunction
function! FrontExtractor( val ) abort
    return a:val[0]
endfunction
call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(ingo#dict#FromValues(function('BothExtractor'), []), {}, 'create with empty values')
call vimtap#Is(ingo#dict#FromValues(function('BothExtractor'), ['foo', 'bar', 'baz']), {'fo': 'foo', 'br': 'bar', 'bz': 'baz'}, 'create with keys from first + last letter')
call vimtap#Is(ingo#dict#FromValues(function('FrontExtractor'), ['foo', 'bar', 'baz']), {'f': 'foo', 'b': 'baz'}, 'create with keys from first letter, removing duplicate')

call vimtest#Quit()
