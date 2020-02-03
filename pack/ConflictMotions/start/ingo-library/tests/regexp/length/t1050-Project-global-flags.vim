" Test estimation of matched characters in patterns with global flags.

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#regexp#length#Project('\cfoo'), [3, 3], 'word with case-insensitive flag')
call vimtap#Is(ingo#regexp#length#Project('\cf\Co\co\C'), [3, 3], 'word with multiple case-[in]sensitive flags')

call vimtap#Is(ingo#regexp#length#Project('\%#=2foo'), [3, 3], 'word with regexp engine type flag')
call vimtap#Is(ingo#regexp#length#Project('\%#=2\cfoo'), [3, 3], 'word with regexp engine type and case-insensitive flags')

call vimtest#Quit()
