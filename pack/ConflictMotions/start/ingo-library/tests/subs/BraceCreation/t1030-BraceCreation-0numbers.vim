" Test brace creation with 0-prefixed numbers.

call vimtest#StartTap()
call vimtap#Plan(4)

function! s:Call( text )
    return ingo#subs#BraceCreation#FromSplitString(a:text)
endfunction

call vimtap#Is(s:Call('foo1 foo2 foo3'), 'foo{1..3}', 'single digit number sequence')
call vimtap#Is(s:Call('foo01 foo02 foo03'), 'foo0{1..3}', 'single digit 0-number sequence')
call vimtap#Is(s:Call('foo06 foo08 foo10 foo12'), 'foo{06..12..2}', '1-2 digit 0-number sequence')
call vimtap#Is(s:Call('foo005 foo056 foo107 foo158'), 'foo{005..158..51}', '1-3 digit 0-number sequence')

call vimtest#Quit()
