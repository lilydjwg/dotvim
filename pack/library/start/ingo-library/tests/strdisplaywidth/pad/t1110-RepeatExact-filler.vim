" Test duplicate to exactly match width with custom filler.

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact('', 2, 'x'), 'xx', 'empty text')
call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact('', 5, '.'), '.', 'double-width text')
call vimtap#Is(ingo#strdisplaywidth#pad#RepeatExact("\t\t", 10), '          ', 'two tabs text are rendered as spaces, no filler necessary')

call vimtest#Quit()
