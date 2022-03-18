" Test estimation of matched character multiple times with various multis.

call vimtest#StartTap()
call vimtap#Plan(18)

call vimtap#Is(ingo#regexp#length#Project('a*'), [0, 0x7FFFFFFF], '* multi')
call vimtap#Is(ingo#regexp#length#Project('a\+'), [1, 0x7FFFFFFF], '\+ multi')
call vimtap#Is(ingo#regexp#length#Project('a\?'), [0, 1], '\? multi')
call vimtap#Is(ingo#regexp#length#Project('a\{2,5}'), [2, 5], '\{n,m} multi')
call vimtap#Is(ingo#regexp#length#Project('a\{3}'), [3, 3], '\{n} multi')
call vimtap#Is(ingo#regexp#length#Project('a\{3,}'), [3, 0x7FFFFFFF], '\{n,} multi')
call vimtap#Is(ingo#regexp#length#Project('a\{,3}'), [0, 3], '\{,n} multi')
call vimtap#Is(ingo#regexp#length#Project('a\{}'), [0, 0x7FFFFFFF], '\{} multi')
call vimtap#Is(ingo#regexp#length#Project('a\{-2,5}'), [2, 5], '\{-n,m} multi')
call vimtap#Is(ingo#regexp#length#Project('a\{-3}'), [3, 3], '\{-n} multi')
call vimtap#Is(ingo#regexp#length#Project('a\{-3,}'), [3, 0x7FFFFFFF], '\{-n,} multi')
call vimtap#Is(ingo#regexp#length#Project('a\{-,3}'), [0, 3], '\{-,n} multi')
call vimtap#Is(ingo#regexp#length#Project('a\{-}'), [0, 0x7FFFFFFF], '\{-} multi')

call vimtap#Is(ingo#regexp#length#Project('a\@>'), [1, 1], '\@> multi')
call vimtap#Is(ingo#regexp#length#Project('a\@='), [0, 0], '\@= multi')
call vimtap#Is(ingo#regexp#length#Project('a\@!'), [0, 0], '\@! multi')
call vimtap#Is(ingo#regexp#length#Project('a\@<='), [0, 0], '\@<= multi')
call vimtap#Is(ingo#regexp#length#Project('a\@<!'), [0, 0], '\@<! multi')

call vimtest#Quit()
