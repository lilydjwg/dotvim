" Test adding offsets with wrap-around.

call vimtest#StartTap()
call vimtap#Plan(12)

call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(2, 1, 10), 3, 'simple add')
call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(2, 7, 10), 9, 'simple add')
call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(2, 8, 10), 10, 'simple add to max')
call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(2, 9, 10), 1, 'wrap-around')
call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(2, 13, 10), 5, 'more wrap-around')
call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(2, 23, 10), 5, 'wrap-around twice')

call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(5, -3, 10), 2, 'subtract')
call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(2, -1, 10), 1, 'subtract to min')
call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(2, -2, 10), 10, 'wrap-around')
call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(2, -3, 10), 9, 'more wrap-around')
call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(2, -13, 10), 9, 'wrap-around twice')
call vimtap#Is(ingo#lnum#AddOffsetWithWrapping(2, -23, 10), 9, 'wrap-around thrice')

call vimtest#Quit()
