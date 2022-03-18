" Test parsing any non-ordinary atoms.

call vimtest#StartTap()
call vimtap#Plan(11)

call vimtap#Is(substitute('foobar', ingo#regexp#parse#NonOrdinaryAtomExpr(), '', 'g'), 'foobar', 'no non-ordinary atoms')
call vimtap#Is(substitute('fo\+ba*r', ingo#regexp#parse#NonOrdinaryAtomExpr(), '', 'g'), 'fobar', '\+ and *')
call vimtap#Is(substitute('|(f)\|oo\(b\%(a\|u\+\)r\)', ingo#regexp#parse#NonOrdinaryAtomExpr(), '', 'g'), '|(f)oobaur', 'complex branches and nested groups')
call vimtap#Is(substitute('fo\{-}ba\{-1}r\{-,10} \{2,7}x\\{1,2}', ingo#regexp#parse#NonOrdinaryAtomExpr(), '', 'g'), 'fobar x\\{1,2}', 'various \{} multis')
call vimtap#Is(substitute('^foo\%>42lbar$', ingo#regexp#parse#NonOrdinaryAtomExpr(), '', 'g'), 'foobar', '^ \%>l $')
call vimtap#Is(substitute('f..b\_.r', ingo#regexp#parse#NonOrdinaryAtomExpr(), '', 'g'), 'fbr', '. and \_.')
call vimtap#Is(substitute('\%d34foo\%u03eabar\%xFFr', ingo#regexp#parse#NonOrdinaryAtomExpr(), '', 'g'), 'foobarr', '\%d \%u \%x')
call vimtap#Is(substitute('\%#=2f\(oo\)b\([aeiou]\)r-\1\2', ingo#regexp#parse#NonOrdinaryAtomExpr(), '', 'g'), 'foobr-', 'regexp with re, capture groups and references')
call vimtap#Is(substitute('\if\I\k\K\f\F\p\Po\s\So\d\D\x\Xb\o\O\wa\W\h\H\a\A\l\L\u\Ur', ingo#regexp#parse#NonOrdinaryAtomExpr(), '', 'g'), 'foobar', 'character classes')
call vimtap#Is(substitute('f[^[:lower:]]oob[[:alpha:]]ar[[:space:][:xdigit:]]', ingo#regexp#parse#NonOrdinaryAtomExpr(), '', 'g'), 'foobar', 'collection classes')
call vimtap#Is(substitute('f[^oO]\%[bar]', ingo#regexp#parse#NonOrdinaryAtomExpr(), '', 'g'), 'f', 'inverted collection and optional sequence')

call vimtest#Quit()
