" Test that lines from a file do no modify the cache itself.

call vimtest#StartTap()
call vimtap#Plan(4)

let s:lines = ingo#file#GetLines('lorem.txt')
let s:firstLine = s:lines[0]
call vimtap#Is(len(ingo#file#GetLines('lorem.txt')), 3, 'Get lorem')

call remove(s:lines, -1)
let s:lines[0] = 'Changed!'
call vimtap#Is(len(s:lines), 2, 'Removed last line')

call vimtap#Is(len(ingo#file#GetLines('lorem.txt')), 3, 'Get lorem again still returns three lines')
call vimtap#Is(ingo#file#GetLines('lorem.txt')[0], s:firstLine, 'Get lorem again still returns the original first line')

call vimtest#Quit()
