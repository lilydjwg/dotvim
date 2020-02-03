" Test return value from joining of lines.

call vimtest#StartTap()
call vimtap#Plan(2)

call append(0, ['plain', 'next'])
call vimtap#Is(ingo#join#Lines(1, 1, ''), 1, 'plain join successful')

call append(line('$'), ['plain'])
call vimtap#Is(ingo#join#Lines(line('$'), 1, ''), 0, 'cannot join at last line')

call vimtest#Quit()
