" Test estimation of matched characters in patterns with collections.

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#regexp#length#Project('ab[cdef]'), [3, 3], 'word with one collection')
call vimtap#Is(ingo#regexp#length#Project('[Aa]b\_[cdef]'), [3, 3], 'word with two collections, one the EOL variant')
call vimtap#Is(ingo#regexp#length#Project('[Aa][Bc][Cc]'), [3, 3], 'three concatenated collections')

call vimtap#Is(ingo#regexp#length#Project('ab\[cdef\]'), [8, 8], 'word with escaped collection characters')

call vimtest#Quit()
