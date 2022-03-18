" Test clearing records for unique return values.

function! TestFunction()
    return remove(s:values, 0)
endfunction

call vimtest#StartTap()
call vimtap#Plan(3)

let s:values = [1, 1, 3, 4]
call vimtap#Is(ingo#function#uniquify#ReturnValue('t1', 'TestFunction'), 1, 't1 1.')
call ingo#function#uniquify#Clear('t1')
call vimtap#Is(ingo#function#uniquify#ReturnValue('t1', 'TestFunction'), 1, 't1 after clear')
call vimtap#Is(ingo#function#uniquify#ReturnValue('t1', 'TestFunction'), 3, 't1 3.')

call vimtest#Quit()
