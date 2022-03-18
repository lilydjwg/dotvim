" Test separating global flags from the pattern

call vimtest#StartTap()
call vimtap#Plan(14)

call vimtap#Is(ingo#regexp#split#GlobalFlags(''), ['', '', ''], 'empty pattern')
call vimtap#Is(ingo#regexp#split#GlobalFlags('foo\|bar'), ['', '', 'foo\|bar'], 'no flags')

call vimtap#Is(ingo#regexp#split#GlobalFlags('\cfoo\|bar'), ['', '\c', 'foo\|bar'], 'case-insensitive flag at the beginning')
call vimtap#Is(ingo#regexp#split#GlobalFlags('foo\|bar\c'), ['', '\c', 'foo\|bar'], 'case-insensitive flag at the end')
call vimtap#Is(ingo#regexp#split#GlobalFlags('foo\|\Cbar'), ['', '\C', 'foo\|bar'], 'case-sensitive flag in the middle')
call vimtap#Is(ingo#regexp#split#GlobalFlags('\Cfoo\|\Cbar\C'), ['', '\C', 'foo\|bar'], 'multiple case-sensitive flags')
call vimtap#Is(ingo#regexp#split#GlobalFlags('\Cfo\co\|\Cb\car\C'), ['', '\c', 'foo\|bar'], 'multiple case-[in]sensitive flags; \c wins if it occurs')
call vimtap#Is(ingo#regexp#split#GlobalFlags('foo\|\\cbar'), ['', '', 'foo\|\\cbar'], 'pattern with \\c')
call vimtap#Is(ingo#regexp#split#GlobalFlags('\c'), ['', '\c', ''], 'only case-insensitive flag, empty pattern')

call vimtap#Is(ingo#regexp#split#GlobalFlags('\%#=1foo\|bar'), ['\%#=1', '', 'foo\|bar'], 'engine type 1 flag at the beginning')
call vimtap#Is(ingo#regexp#split#GlobalFlags('\%#=1foo\|\%#=0bar'), ['\%#=1', '', 'foo\|bar'], 'engine flags at beginning and middle; first wins')
call vimtap#Is(ingo#regexp#split#GlobalFlags('foo\|b\%#=2ar'), ['\%#=2', '', 'foo\|bar'], 'engine type 2 flag in the middle')
call vimtap#Is(ingo#regexp#split#GlobalFlags('\\%#=1foo\|bar'), ['', '', '\\%#=1foo\|bar'], 'pattern with \\%#=1')

call vimtap#Is(ingo#regexp#split#GlobalFlags('\%#=1\cfoo\|\Cbar'), ['\%#=1', '\c', 'foo\|bar'], 'engine type 1 and case insensitive flag at the beginning, ignored case sensitive flag in the middle')

call vimtest#Quit()
