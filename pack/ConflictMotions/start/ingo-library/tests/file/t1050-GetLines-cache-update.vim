" Test getting lines from a file that is updated and then deleted.

let s:tempfile = tempname()
call writefile(['foo', 'bar'], s:tempfile, 's')

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#file#GetLines(s:tempfile), ['foo', 'bar'], 'Get tempfile')

sleep 1
call writefile(['fox', 'booze', 'more'], s:tempfile, 's')
call vimtap#Is(ingo#file#GetLines(s:tempfile), ['fox', 'booze', 'more'], 'Get updated tempfile')

sleep 1
if delete(s:tempfile) != 0
    call vimtap#BailOut('Failed to delete temp file: ' . s:tempfile)
endif
call vimtap#Is(ingo#file#GetLines(s:tempfile), [], 'Get deleted tempfile returns empty List')
call vimtap#Is(ingo#file#GetCachedFilesByAge(), [], 'Nothing is cached any longer')

call vimtest#Quit()
