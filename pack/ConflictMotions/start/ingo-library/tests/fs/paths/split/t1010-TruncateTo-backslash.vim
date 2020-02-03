" Test truncation of backslash-separated filespec.

scriptencoding utf-8

call vimtest#StartTap()
call vimtap#Plan(2)
let s:longFile = 'C:\tmp\with one of\these\very\loooooong\path\in\there\before\filename.txt'

call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 50, '\'), 'C:\tmp\with one of\…\in\there\before\filename.txt', 'drop four directories')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 50, '/'), 'C:\tmp\with one of\these\…here\before\filename.txt', 'truncation as one string with wrong path separator')

call vimtest#Quit()
