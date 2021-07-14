" Test undoing of smartcasing pattern.

function! s:DoUndo( pattern ) abort
    return ingo#smartcase#Undo(ingo#smartcase#FromPattern(a:pattern))
endfunction

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(s:DoUndo('fooBar'), 'fooBar', 'Undo of smartcased fooBar')
call vimtap#Is(s:DoUndo('foo bar'), 'foobar', 'Undo of smartcased foo bar')
call vimtap#Is(s:DoUndo('foo'), 'foo', 'Undo of smartcased foo')
call vimtap#Is(s:DoUndo('FOO'), 'FOO', 'Undo of smartcased FOO')
call vimtap#Is(s:DoUndo('not one'), 'notone', 'Undo of smartcased not one')

call vimtest#Quit()
