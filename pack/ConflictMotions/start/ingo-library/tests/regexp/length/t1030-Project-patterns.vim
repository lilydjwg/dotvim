" Test estimation of matched characters in simple patterns without multis or groups.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#regexp#length#Project('\<abc\>'), [3, 3], '3-character keyword')
call vimtap#Is(ingo#regexp#length#Project('^abc$'), [3, 3], '3-character anchored line')
call vimtap#Is(ingo#regexp#length#Project('\%>10l\%<80vword\%$'), [4, 4], '4-character position-anchored word')

call vimtap#Is(ingo#regexp#length#Project('foo\.\.\.'), [6, 6], 'word with ellipsis')
call vimtap#Is(ingo#regexp#length#Project('\tThis is\tit\n'), [12, 12], 'sentence with tabs and newline')
call vimtap#Is(ingo#regexp#length#Project('/\~-\~-\*-\*\\'), [9, 9], 'mix of escaped special characters')

call vimtest#Quit()
