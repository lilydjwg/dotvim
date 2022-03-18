" Test joining of lines with closing parenthesis.

call append(0, ['plain', ') parenthesis'])
call ingo#join#Lines(1, 1, '')

call append(0, ['4space    ', ') parenthesis'])
call ingo#join#Lines(1, 1, '')

call append(0, ["tab\t", ') parenthesis'])
call ingo#join#Lines(1, 1, '')

call append(0, ['softtabstop    ', ') parenthesis'])
call ingo#join#Lines(1, 1, '')


call append(0, ['plain', ' ) indented parenthesis'])
call ingo#join#Lines(1, 1, '')

call append(0, ['4space    ', '    ) indented parenthesis'])
call ingo#join#Lines(1, 1, '')

call append(0, ["tab\t", "\t) indented parenthesis"])
call ingo#join#Lines(1, 1, '')

call append(0, ['softtabstop    ', "\t  ) indented parenthesis"])
call ingo#join#Lines(1, 1, '')


call append(0, ['plain', ') parenthesis with ;; separator'])
call ingo#join#Lines(1, 1, ';;')

call append(0, ['4space    ', ') parenthesis with ;; separator'])
call ingo#join#Lines(1, 1, ';;')

call append(0, ["tab\t", ') parenthesis with ;; separator'])
call ingo#join#Lines(1, 1, ';;')

call append(0, ['softtabstop    ', ') parenthesis with ;; separator'])
call ingo#join#Lines(1, 1, ';;')

call vimtest#SaveOut()
call vimtest#Quit()
