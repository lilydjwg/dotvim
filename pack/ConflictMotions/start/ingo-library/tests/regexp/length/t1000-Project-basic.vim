" Test estimation of matched characters.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#regexp#length#Project(''), [0, 0], 'empty pattern')
call vimtap#Is(ingo#regexp#length#Project('a'), [1, 1], 'single literal character')
call vimtap#Is(ingo#regexp#length#Project('abc'), [3, 3], '3-character literal word')

call vimtap#Is(ingo#regexp#length#Project('a\|xyz'), [1, 3], 'two literal branches')
call vimtap#Is(ingo#regexp#length#Project('abc\|z'), [1, 3], 'two literal branches')
call vimtap#Is(ingo#regexp#length#Project('a\|fghijklm\|xyz'), [1, 8], 'three literal branches')

call vimtest#Quit()
