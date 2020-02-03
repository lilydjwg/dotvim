" Test addition of literal patterns based on length.

call vimtest#StartTap()
call vimtap#Plan(8)

call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength([], 'foo'), ['foo'], 'add literal pattern to empty list')
call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['foo'], 'fo'), ['foo', 'fo'], 'add shorter literal pattern to one-element list')
call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['foo'], 'fooy'), ['fooy', 'foo'], 'add longer literal pattern to one-element list')
call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['foo'], 'fox'), ['foo', 'fox'], 'add same-length literal pattern to one-element list')

call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['foo', 'fo'], 'f'), ['foo', 'fo', 'f'], 'add shorter literal pattern to two-element list')
call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['fooxies', 'fo'], 'foox'), ['fooxies', 'foox', 'fo'], 'add literal pattern to middle of two-element list')
call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['fooxies', 'foox', 'fo'], 'foo'), ['fooxies', 'foox', 'foo', 'fo'], 'add literal pattern to middle of three-element list')

call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['fooxies', 'fo', 'boobies', 'bo'], 'boo'), ['fooxies', 'boo', 'fo', 'boobies', 'bo'], 'add literal pattern to middle of not fully sorted four-element list')

call vimtest#Quit()
