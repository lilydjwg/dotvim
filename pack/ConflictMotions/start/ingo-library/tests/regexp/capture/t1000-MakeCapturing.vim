" Test conversion of capturing groups into non-capturing ones.

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#regexp#capture#MakeNonCapturing('^\(foo\|ba\(r\|la\|lo\)\)-\(no\%(hi\)\?\)'), '^\%(foo\|ba\%(r\|la\|lo\)\)-\%(no\%(hi\)\?\)', 'make all non-capturing')
call vimtap#Is(ingo#regexp#capture#MakeNonCapturing('^\(foo\|ba\(r\|la\|lo\)\)-\(no\%(hi\)\?\)', [0, 2]), '^\%(foo\|ba\(r\|la\|lo\)\)-\%(no\%(hi\)\?\)', 'make some non-capturing')

call vimtap#Is(ingo#regexp#capture#MakeCapturing('^\%(foo\|ba\%(r\|la\|lo\)\)-\%(no\(hi\)\?\)'), '^\(foo\|ba\(r\|la\|lo\)\)-\(no\(hi\)\?\)', 'make all capturing')
call vimtap#Is(ingo#regexp#capture#MakeCapturing('^\%(foo\|ba\%(r\|la\|lo\)\)-\%(no\(hi\)\?\)', [0, 2]), '^\(foo\|ba\%(r\|la\|lo\)\)-\(no\(hi\)\?\)', 'make some capturing')

call vimtest#Quit()
