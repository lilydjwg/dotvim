" Test unique return values.

function! TestFunction()
    return remove(s:values, 0)
endfunction

call vimtest#StartTap()
call vimtap#Plan(9)

let s:values = [1, 2, 3]
call vimtap#Is(ingo#function#uniquify#ReturnValue('t1', 'TestFunction'), 1, 't1 1.')
call vimtap#Is(ingo#function#uniquify#ReturnValue('t1', 'TestFunction'), 2, 't1 2.')
call vimtap#Is(ingo#function#uniquify#ReturnValue('t1', 'TestFunction'), 3, 't1 3.')

let s:values = [1, 1, 3, 4]
call vimtap#Is(ingo#function#uniquify#ReturnValue('t2', 'TestFunction'), 1, 't2 1.')
call vimtap#Is(ingo#function#uniquify#ReturnValue('t2', 'TestFunction'), 3, 't2 2.')
call vimtap#Is(ingo#function#uniquify#ReturnValue('t2', 'TestFunction'), 4, 't2 3.')

let s:values = [1, 1, 1, 4, 4, 4, 4, 5]
call vimtap#Is(ingo#function#uniquify#ReturnValue('t3', 'TestFunction'), 1, 't3 1.')
call vimtap#Is(ingo#function#uniquify#ReturnValue('t3', 'TestFunction'), 4, 't3 2.')
call vimtap#Is(ingo#function#uniquify#ReturnValue('t3', 'TestFunction'), 5, 't3 3.')

call vimtest#Quit()
