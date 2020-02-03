" Test gettings lines from a file with a too small small cache.

let g:IngoLibrary_FileCacheMaxSize = 200

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(len(ingo#file#GetLines('ipsum.txt')), 4, 'Get ipsum')
call vimtap#Is(ingo#file#GetCachedFilesByAge(), [], 'ipsum too large; nothing cached')

call vimtap#Is(len(ingo#file#GetLines('lorem.txt')), 3, 'Get lorem')
call vimtap#Is(len(ingo#file#GetCachedFilesByAge()), 1, 'lorem cached, it fits the cache')

call vimtest#Quit()
