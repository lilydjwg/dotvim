" Test parsing of other atoms.

call vimtest#StartTap()
call vimtap#Plan(9)

call vimtap#Is(substitute('foobar', ingo#regexp#parse#OtherAtomExpr(), '', 'g'), 'foobar', 'no other atoms')
call vimtap#Is(substitute('^\<fo[ox]\%(bar\|hos\)\>', ingo#regexp#parse#OtherAtomExpr(), '', 'g'), '^\<fo[ox]\%(bar\|hos\)\>', 'no other atoms in complex pattern')
call vimtap#Is(substitute('\%#=1foobar', ingo#regexp#parse#OtherAtomExpr(), '', 'g'), 'foobar', 'regexp engine atom')
call vimtap#Is(substitute('bad\%#=1foobar', ingo#regexp#parse#OtherAtomExpr(), '', 'g'), 'bad\%#=1foobar', 'regexp engine atom not in front')
call vimtap#Is(substitute('foo\zsb\zear', ingo#regexp#parse#OtherAtomExpr(), '', 'g'), 'foobar', '\zs and \ze')
call vimtap#Is(substitute('foo\nbar', ingo#regexp#parse#OtherAtomExpr(), '', 'g'), 'foo\nbar', '\n')
call vimtap#Is(substitute('f\(o\+\)b\1r', ingo#regexp#parse#OtherAtomExpr(), '', 'g'), 'f\(o\+\)br', '\1')
call vimtap#Is(substitute('\cfoobar', ingo#regexp#parse#OtherAtomExpr(), '', 'g'), 'foobar', '\c')
call vimtap#Is(substitute('\C\V', ingo#regexp#parse#OtherAtomExpr(), '', 'g'), '', '\C\V')

call vimtest#Quit()
