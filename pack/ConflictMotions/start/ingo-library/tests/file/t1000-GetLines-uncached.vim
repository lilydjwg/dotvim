" Test gettings lines from a file without the cache.

let g:IngoLibrary_FileCacheMaxSize = 0

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(len(ingo#file#GetLines('lorem.txt')), 3, 'Get lorem')
call vimtap#Is(ingo#file#GetCachedFilesByAge(), [], 'Nothing cached')
call vimtap#Is(len(ingo#file#GetLines('ipsum.txt')), 4, 'Get ipsum')
call vimtap#Is(len(ingo#file#GetLines('nulla.txt')), 6, 'Get nulla')
call vimtap#Is(len(ingo#file#GetLines('lorem.txt')), 3, 'Get lorem again')
call vimtap#Is(ingo#file#GetCachedFilesByAge(), [], 'Nothing cached')

call vimtest#Quit()
