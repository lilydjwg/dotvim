" Test duplicate to exactly match width.

call vimtest#StartTap()
call vimtap#Plan(10)

call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact('', 1), ' ', 'empty text')
call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact('x', 5), 'xxxxx', 'single-width text')
call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact('Abc', 1), 'A', 'text longer than enough')
call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact('Abc', 3), 'Abc', 'text exactly long enough')
call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact('Abc', 4), 'AbcA', 'need one duplication to exceed')
call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact('Abc', 6), 'AbcAbc', 'need one duplication to match')
call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact('Abc', 7), 'AbcAbcA', 'need two duplications to exceed')

call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact('', 5), ' ', 'double-width text')
call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact("\t\t", 10), '          ', 'two tabs text are rendered as spaces')
call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact("|\t", 10), '|       | ', 'char+tab text is duplicated')

call vimtest#Quit()
