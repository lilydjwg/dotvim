" Test joining of indented lines.

call append(0, ['4space', '    indented'])
call ingo#join#Lines(1, 1, '')

call append(0, ['tab', "\tindented"])
call ingo#join#Lines(1, 1, '')

call append(0, ['softtabstop', "\t    indented"])
call ingo#join#Lines(1, 1, '')

call append(0, ['4space', '    indented with space separator'])
call ingo#join#Lines(1, 1, ' ')

call append(0, ['tab', "\tindented with space separator"])
call ingo#join#Lines(1, 1, ' ')

call append(0, ['softtabstop', "\t    indented with space separator"])
call ingo#join#Lines(1, 1, ' ')

call append(0, ['4space', '    indented with ;; separator'])
call ingo#join#Lines(1, 1, ';;')

call append(0, ['tab', "\tindented with ;; separator"])
call ingo#join#Lines(1, 1, ';;')

call append(0, ['softtabstop', "\t    indented with ;; separator"])
call ingo#join#Lines(1, 1, ';;')

call vimtest#SaveOut()
call vimtest#Quit()
