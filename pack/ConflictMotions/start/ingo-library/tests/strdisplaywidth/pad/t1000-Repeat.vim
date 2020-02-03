" Test duplicate to exceed width.

call vimtest#StartTap()
call vimtap#Plan(10)

call vimtap#Is(ingo#strdisplaywidth#pad#Repeat('', 1), '', 'empty text')
call vimtap#Is(ingo#strdisplaywidth#pad#Repeat('x', 5), 'xxxxx', 'single-width text')
call vimtap#Is(ingo#strdisplaywidth#pad#Repeat('Abc', 1), 'Abc', 'text longer than enough')
call vimtap#Is(ingo#strdisplaywidth#pad#Repeat('Abc', 3), 'Abc', 'text exactly long enough')
call vimtap#Is(ingo#strdisplaywidth#pad#Repeat('Abc', 4), 'AbcAbc', 'need one duplication to exceed')
call vimtap#Is(ingo#strdisplaywidth#pad#Repeat('Abc', 6), 'AbcAbc', 'need one duplication to match')
call vimtap#Is(ingo#strdisplaywidth#pad#Repeat('Abc', 7), 'AbcAbcAbc', 'need two duplications to exceed')

call vimtap#Is(ingo#strdisplaywidth#pad#Repeat('', 5), '', 'double-width text')
call vimtap#Is(ingo#strdisplaywidth#pad#Repeat("\t\t", 10), '                ', 'two tabs text are rendered as spaces')
call vimtap#Is(ingo#strdisplaywidth#pad#Repeat("|\t", 10), '|       |       ', 'char+tab text is duplicated')

call vimtest#Quit()
