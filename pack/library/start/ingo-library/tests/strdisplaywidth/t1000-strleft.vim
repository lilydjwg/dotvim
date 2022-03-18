" Test extracting a certain width from left.

call vimtest#StartTap()
call vimtap#Plan(8)

call vimtap#Is(ingo#strdisplaywidth#strleft('foobar', 2), 'fo', '2 single-width characters')
call vimtap#Is(ingo#strdisplaywidth#strleft('foobar', 9), 'foobar', 'width exceeds actual one')
call vimtap#Is(ingo#strdisplaywidth#strleft('foobar', 0), '', 'zero width')

call vimtap#Is(ingo#strdisplaywidth#strleft('fbar', 2), 'f', 'double-width character in the middle is excluded')
call vimtap#Is(ingo#strdisplaywidth#strleft('fbar', 3), 'f', 'include double-width character')
call vimtap#Is(ingo#strdisplaywidth#strleft('fbar', 4), 'f', 'double-width character in the middle is excluded')
call vimtap#Is(ingo#strdisplaywidth#strleft("f\tbar", 3), 'f', 'tab in the middle is excluded')
call vimtap#Is(ingo#strdisplaywidth#strleft("f\t\tbar", 8), "f\t", 'include tab')

call vimtest#Quit()
