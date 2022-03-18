" Test recurring substitution.

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(ingo#subst#Recurringly('foobar', 'o', 'X', 'g'), 'fXXbar', 'plain foobar global substitution')
call vimtap#Is(ingo#subst#Recurringly('foobar', 'o', 'X', ''), 'fXXbar', 'foobar once substitution is equivalent to global substitution')

call vimtap#Is(ingo#subst#Recurringly('camelCaseConstructCreation', '\(\k*\%(\k\&\U\)\+\)\(\u\k\+\)', '\1 \L\2', 'g'), 'camel case construct creation', 'split all camelCase humps')

call vimtap#Is(ingo#subst#Recurringly('foobar', '[^o]\zso\{2,6}\ze[^o]', '&o', 'g'), 'fooooooobar', 'limit appending via multi')
call vimtap#Is(ingo#subst#Recurringly('foobar', 'o\+', '&o', 'g', 5), 'fooooooobar', 'stop endless appending after 5 counts')

call vimtest#Quit()
