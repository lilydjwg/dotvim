" Test strftime() emulation.

function! MyTime( format, ... )
    return (a:0 ? a:1[0] . a:1[0] . ':' . a:1[1] . a:1[1] : '23:59')
endfunction
let g:IngoLibrary_StrftimeEmulation = {'%Y': '1999', '%H:%M': function('MyTime'), '*': 'Joker'}

call vimtest#StartTap()
call vimtap#Plan(7)

call vimtap#Is(ingo#date#strftime('%Y'), '1999', 'Emulated %Y')
call vimtap#Is(ingo#date#strftime('%Y', 1540148357), '1999', 'Emulated %Y with time')

call vimtap#Is(ingo#date#strftime('%H:%M'), '23:59', 'Emulated %H:M')
call vimtap#Is(ingo#date#strftime('%H:%M', 1540148357), '11:55', 'Emulated %H:M with time')

call vimtap#Is(ingo#date#strftime('%c'), 'Joker', 'Emulated fallback')
call vimtap#Is(ingo#date#strftime('%c', 1540148357), 'Joker', 'Emulated fallback with time')

unlet g:IngoLibrary_StrftimeEmulation['*']
call vimtap#err#Throws('strftime: Unhandled format %c and no fallback * key in g:IngoLibrary_StrftimeEmulation', "call ingo#date#strftime('%c')", 'Exception without fallback')

call vimtest#Quit()
