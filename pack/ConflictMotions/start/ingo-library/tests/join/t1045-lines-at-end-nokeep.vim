" Test joining of lines at end of buffer not keeping whitespace.
" Tests that trailing whitespace is kept, as no join takes place.

call append(line('$'), ['plain'])
call ingo#join#Lines(line('$'), 0, '')

call append(line('$'), ['4space    '])
call ingo#join#Lines(line('$'), 0, '')

call append(line('$'), ["tab\t"])
call ingo#join#Lines(line('$'), 0, '')

call append(line('$'), ['softtabstop    '])
call ingo#join#Lines(line('$'), 0, '')

call vimtest#SaveOut()
call vimtest#Quit()
