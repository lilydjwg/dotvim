" Test gettings lines from a file with a small cache.

let g:IngoLibrary_FileCacheMaxSize = 600

function! s:GetCachedFilenamesByAge()
    return map(ingo#file#GetCachedFilesByAge(), 'fnamemodify(v:val, ":t:r")')
endfunction
call vimtest#StartTap()
call vimtap#Plan(15)

call vimtap#Is(len(ingo#file#GetLines('lorem.txt')), 3, 'Get lorem')
call vimtap#Is(s:GetCachedFilenamesByAge(), ['lorem'], 'lorem cached')

call vimtap#Is(len(ingo#file#GetLines('lorem.txt')), 3, 'Get lorem again')
call vimtap#Is(s:GetCachedFilenamesByAge(), ['lorem'], 'lorem cached')

sleep 1
call vimtap#Is(len(ingo#file#GetLines('ipsum.txt')), 4, 'Get ipsum')
call vimtap#Is(s:GetCachedFilenamesByAge(), ['lorem', 'ipsum'], 'lorem > ipsum cached')

sleep 1
call vimtap#Is(len(ingo#file#GetLines('lorem.txt')), 3, 'Get lorem again')
call vimtap#Is(s:GetCachedFilenamesByAge(), ['ipsum', 'lorem'], 'ipsum > lorem cached')

sleep 1
call vimtap#Is(len(ingo#file#GetLines('nulla.txt')), 6, 'Get nulla')
call vimtap#Is(s:GetCachedFilenamesByAge(), ['lorem', 'nulla'], 'lorem > nulla cached; ipsum got evicted')

sleep 1
call vimtap#Is(len(ingo#file#GetLines('ipsum.txt')), 4, 'Get ipsum again')
sleep 1
call vimtap#Is(len(ingo#file#GetLines('nulla.txt')), 6, 'Get nulla again')
call vimtap#Is(s:GetCachedFilenamesByAge(), ['nulla'], 'only nulla cached; ipsum got evicted')

sleep 1
call vimtap#Is(len(ingo#file#GetLines('lorem.txt')), 3, 'Get lorem again')
call vimtap#Is(s:GetCachedFilenamesByAge(), ['nulla', 'lorem'], 'nulla > lorem cached')

call vimtest#Quit()
