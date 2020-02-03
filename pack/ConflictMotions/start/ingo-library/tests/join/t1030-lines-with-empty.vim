" Test joining of lines with following empty line.

call append(0, ['plain', ''])
call ingo#join#Lines(1, 1, '')

call append(0, ['4space    ', ''])
call ingo#join#Lines(1, 1, '')

call append(0, ["tab\t", ''])
call ingo#join#Lines(1, 1, '')

call append(0, ['softtabstop    ', ''])
call ingo#join#Lines(1, 1, '')

call vimtest#SaveOut()
call vimtest#Quit()
