" Test removing position atoms.

call vimtest#StartTap()
call vimtap#Plan(7)

call vimtap#Is(ingo#regexp#deconstruct#RemovePositionAtoms('foobar'), 'foobar', 'no position atoms')
call vimtap#Is(ingo#regexp#deconstruct#RemovePositionAtoms('fo\{1,10}bar\? .* l\([aeiou]\)ll\1'), 'fo\{1,10}bar\? .* l\([aeiou]\)ll\1', 'only various other atoms')
call vimtap#Is(ingo#regexp#deconstruct#RemovePositionAtoms('^fo\+bar$'), 'fo\+bar', 'beginning and end of line atoms')
call vimtap#Is(ingo#regexp#deconstruct#RemovePositionAtoms('\<foobar\>'), 'foobar', 'beginning and end of word atoms')
call vimtap#Is(ingo#regexp#deconstruct#RemovePositionAtoms('\%^file\%$'), 'file', 'beginning and end of file atoms')
call vimtap#Is(ingo#regexp#deconstruct#RemovePositionAtoms('the \%Vfoo\%V here'), 'the foo here', 'two visual area atoms')
call vimtap#Is(ingo#regexp#deconstruct#RemovePositionAtoms('found \%10l\%>2chere\s.*\%<20v\%>''x'), 'found here\s.*', 'various line, column, mark atoms')

call vimtest#Quit()
