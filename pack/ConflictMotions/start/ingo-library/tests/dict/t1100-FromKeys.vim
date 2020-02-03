" Test creating Dict from keys.

call vimtest#StartTap()
call vimtap#Plan(2)

call vimtap#Is(ingo#dict#FromKeys([], 1), {}, 'create with empty keys')
call vimtap#Is(ingo#dict#FromKeys(['foo', 'bar', 'baz'], 1), {'foo': 1, 'bar': 1, 'baz': 1}, 'create with default value 1')

call vimtest#Quit()
