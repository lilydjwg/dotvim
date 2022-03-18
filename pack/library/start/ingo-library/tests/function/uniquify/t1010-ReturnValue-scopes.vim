" Test unique return values with different scopes.

function! TestFunctionA()
    return remove(s:valuesA, 0)
endfunction
function! TestFunctionB()
    return remove(s:valuesB, 0)
endfunction

call vimtest#StartTap()
call vimtap#Plan(6)

let s:valuesA = [1, 1, 3, 4]
let s:valuesB = [1, 1, 9, 3]
call vimtap#Is(ingo#function#uniquify#ReturnValue('A', 'TestFunctionA'), 1, 'A 1.')
call vimtap#Is(ingo#function#uniquify#ReturnValue('B', 'TestFunctionB'), 1, 'B 1.')
call vimtap#Is(ingo#function#uniquify#ReturnValue('A', 'TestFunctionA'), 3, 'A 2.')
call vimtap#Is(ingo#function#uniquify#ReturnValue('B', 'TestFunctionB'), 9, 'B 2.')
call vimtap#Is(ingo#function#uniquify#ReturnValue('A', 'TestFunctionA'), 4, 'A 3.')
call vimtap#Is(ingo#function#uniquify#ReturnValue('B', 'TestFunctionB'), 3, 'B 3.')

call vimtest#Quit()
