" Test estimation of match length of complex patterns.

call vimtest#StartTap()
call vimtap#Plan(7)

call vimtap#Is(ingo#regexp#length#Project('nu\%(la\)\{2,5}'), [6, 12], '\{n,m} two-character group multi with prefix')
call vimtap#Is(ingo#regexp#length#Project('fo\?\|nul\{2,5}am\|x\{3}'), [1, 9], 'three branches with multi ranges')
call vimtap#Is(ingo#regexp#length#Project('fo\?\|nu\%(la\|y\)\{2,5}am\|x\{3}'), [1, 14], 'three branches, one with inner group with multi')
call vimtap#Is(ingo#regexp#length#Project('fo\?\|nu\%(la\{1,2}\|y\)\{2,5}am\|x\{3}'), [1, 19], 'three branches, one with inner group with multi with multi')
call vimtap#Is(ingo#regexp#length#Project('fo\?\|nu\%(\%(I\%(M\|NN\)\)\{1,2}\|y\)\{2,5}am\|x\{3}'), [1, 34], 'three branches, one with inner group with multi with inner group with multi')

call vimtap#Is(ingo#regexp#length#Project('nul*am\|xu\?t'), [2, 0x7FFFFFFF], 'branches with * / \? multis with prefix and suffix')
call vimtap#Is(ingo#regexp#length#Project('nul\{100,200}am\|xu\{10,99}t'), [12, 204], 'branches with \{n,m} multis with prefix and suffix')

call vimtest#Quit()
