" Test find character sequences.

call vimtest#StartTap()
call vimtap#Plan(11)

call vimtap#Is(ingo#list#sequence#FindCharacter([]), [0, 0], 'empty list')
call vimtap#Is(ingo#list#sequence#FindCharacter(['a']), [0, 0], 'single element list')
call vimtap#Is(ingo#list#sequence#FindCharacter(['a', 123, 'c']), [0, 0], 'non-character element list')
call vimtap#Is(ingo#list#sequence#FindCharacter(['a', 'foo', 'c']), [0, 0], 'non-single-character element list')

call vimtap#Is(ingo#list#sequence#FindCharacter(['b', 'c']), [2, 1], 'b, c list')
call vimtap#Is(ingo#list#sequence#FindCharacter(['c', 'i']), [2, 6], 'c, i list')
call vimtap#Is(ingo#list#sequence#FindCharacter(['b', 'c', 'd']), [3, 1], 'b, c, d list')
call vimtap#Is(ingo#list#sequence#FindCharacter(['c', 'e', 'g', 'i']), [4, 2], 'c, e, g, i list')

call vimtap#Is(ingo#list#sequence#FindCharacter(['b', 'c', 'e']), [2, 1], 'b, c list with additional e')
call vimtap#Is(ingo#list#sequence#FindCharacter(['c', 'e', 'g', 'i', 'f', 'z']), [4, 2], 'c, e, g, i list with additional f, z')

call vimtap#Is(ingo#list#sequence#FindCharacter(['1', 3, '5']), [3, 2], 'list with number')

call vimtest#Quit()
