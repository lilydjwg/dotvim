" Test parsing of character classes.

call vimtest#StartTap()
call vimtap#Plan(2)

call vimtap#Is(substitute('foobar', ingo#regexp#parse#CharacterClassesExpr(), '', 'g'), 'foobar', 'no character classes')
call vimtap#Is(substitute('f\i\I\k\K\fo\F\po\P\sba\S\d\D\x\X\o\O\w\W\h\H\a\A\l\L\u\Ur', ingo#regexp#parse#CharacterClassesExpr(), '', 'g'), 'foobar', 'all character classes')

call vimtest#Quit()
