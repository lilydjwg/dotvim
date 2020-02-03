" Test truncation of filespec in the middle by dropping intermediate directories.

scriptencoding utf-8

call vimtest#StartTap()
call vimtap#Plan(14)

let s:longFile = '/tmp/with/this/very/loooooong/path/in/there/before/filename.txt'
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 63, '/'), s:longFile, 'no change if width at the limit')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 60, '/'), '/tmp/with/this/very/…/path/in/there/before/filename.txt', 'drop one directory')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 53, '/'), '/tmp/with/this/…/path/in/there/before/filename.txt', 'drop two directories')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 52, '/'), '/tmp/with/this/…/path/in/there/before/filename.txt', 'drop three directories')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 40, '/'), '/tmp/with/…/in/there/before/filename.txt', 'drop four directories')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 39, '/'), '/tmp/with/…/there/before/filename.txt', 'drop five directories')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 32, '/'), '/tmp/…/there/before/filename.txt', 'drop six directories, prefer deeper')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 31, '/'), '/tmp/with/…/before/filename.txt', 'drop six directories, have to use shallower')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 30, '/'), '/tmp/…/before/filename.txt', 'drop seven directories')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 19, '/'), '/tmp/…/filename.txt', 'drop eight directories')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 18, '/'), '/…/filename.txt', 'drop nine directories')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 14, '/'), 'filename.txt', 'drop all directories')

call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 10, '/'), 'filen….txt', 'need to truncate even the filename')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 3, '/'), 'f…t', 'excessive truncation to 3')

call vimtest#Quit()
