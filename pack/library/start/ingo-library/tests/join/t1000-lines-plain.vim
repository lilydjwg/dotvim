" Test joining of plain unindented lines.

call append(0, ['plain', 'without separator'])
call ingo#join#Lines(1, 1, '')

call append(0, ['plain', 'with space separator'])
call ingo#join#Lines(1, 1, ' ')

call append(0, ['plain', 'with - separator'])
call ingo#join#Lines(1, 1, '-')

call append(0, ['plain', 'with XX separator'])
call ingo#join#Lines(1, 1, 'XX')

call append(0, ['plain', 'with space-space separator'])
call ingo#join#Lines(1, 1, ' - ')

call vimtest#SaveOut()
call vimtest#Quit()
