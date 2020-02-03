" Test maximum attempts for unique return values.

function! TestFunction()
    return remove(s:values, 0)
endfunction

call vimtest#StartTap()
call vimtap#Plan(2)

let s:values = [1, 1, 1, 1, 5]
call ingo#function#uniquify#SetMaxAttempts('t1', 3)
call vimtap#Is(ingo#function#uniquify#ReturnValue('t1', 'TestFunction'), 1, 't1 1.')
call vimtap#err#Throws('ReturnValue: Too many invocations with same return value: 3', 'call ingo#function#uniquify#ReturnValue("t1", "TestFunction")', 'Unique value only after fourth attempt')

call vimtest#Quit()
