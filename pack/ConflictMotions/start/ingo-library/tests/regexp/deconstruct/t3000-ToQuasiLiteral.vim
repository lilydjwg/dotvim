" Test converting to somewhat literal text.

scriptencoding utf-8

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('foobar'), 'foobar', 'no regexp, already literal text')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('fo*bar\?$'), 'fobar', 'simple regexp')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('^\<fo[ox]\%(bar\|hos\)\>'), 'fo…(bar|hos)', 'medium-complexity regexp')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('^\%10lfo\{1,10}\~bar\?\n.*\t\<l\([aeiou]\)ll\1\>$'), "fo~bar\n.\tl(…)ll\\1", 'complex regexp')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('/a\*b\[cdef\]g\\'), '/a*b[cdef]g\', 'escaped special characters')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('f\(oo\)b\([aeiou]\)r-\1\2'), 'f(oo)b(…)r-\1\2', 'regexp with capture groups and references to them')

call vimtest#Quit()
