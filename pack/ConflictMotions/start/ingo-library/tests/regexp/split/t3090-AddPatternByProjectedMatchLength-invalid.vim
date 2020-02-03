" Test addition of/to invalid patterns.

call vimtest#StartTap()
call vimtap#Plan(2)

call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['fooxies', 'f\%(Foo\|B\(ar\|il\|ox\|Fox\)Trott', 'fo'], 'foo'), ['fooxies', 'f\%(Foo\|B\(ar\|il\|ox\|Fox\)Trott', 'foo', 'fo'], 'add, skip invalid pattern')
call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['fooxies', 'fo'], 'f\%(Foo\|B\(ar\|il\|ox\|Fox\)Trott'), ['fooxies', 'fo', 'f\%(Foo\|B\(ar\|il\|ox\|Fox\)Trott'], 'invalid pattern added at end')

call vimtest#Quit()
