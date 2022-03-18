" Test estimation of complex matches multiple times.

call vimtest#StartTap()
call vimtap#Plan(9)

call vimtap#Is(ingo#regexp#length#Project('nul\{2,5}'), [4, 7], '\{n,m} multi with prefix')
call vimtap#Is(ingo#regexp#length#Project('l\{2,5}am'), [4, 7], '\{n,m} multi with suffix')
call vimtap#Is(ingo#regexp#length#Project('nul\{2,5}am'), [6, 9], '\{n,m} multi with prefix and suffix')

call vimtap#Is(ingo#regexp#length#Project('nu[abcdef]\{2,5}'), [4, 7], '\{n,m} collection multi with prefix')
call vimtap#Is(ingo#regexp#length#Project('nu\t\{2,5}'), [4, 7], '\{n,m} escaped special character multi with prefix')

call vimtap#Is(ingo#regexp#length#Project('nul*am'), [4, 0x7FFFFFFF], '* multi with prefix and suffix')
call vimtap#Is(ingo#regexp#length#Project('nul\+am'), [5, 0x7FFFFFFF], '\+ multi with prefix and suffix')
call vimtap#Is(ingo#regexp#length#Project('nul\{3,}am'), [7, 0x7FFFFFFF], '\{n,} multi with prefix and suffix')

call vimtap#Is(ingo#regexp#length#Project('nul\@=am'), [4, 4], '\@= multi with prefix and suffix')

call vimtest#Quit()
