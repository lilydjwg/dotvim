" Test converting to somewhat literal text.

scriptencoding utf-8

call vimtest#StartTap()
call vimtap#Plan(9)

call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('foobar'), 'foobar', 'no regexp, already literal text')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('fo*bar\?$'), 'fobar', 'simple regexp')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('^\<fo[ox]\%(bar\|hos\)\>'), 'fo…(bar|hos)', 'medium-complexity regexp')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('^\%10lfo\{1,10}\~bar\?\n.*\t\<l\([aeiou]\)ll\1\>$'), "fo~bar\n•\tl(…)ll", 'complex regexp')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('/a\*b\[cdef\]g\\'), '/a*b[cdef]g\', 'escaped special characters')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('f\(oo\)b\([aeiou]\)r-\1\2'), 'f(oo)b(…)r-', 'regexp with capture groups and references to them')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('fo\zsob\zear'), 'foobar', 'regexp with \zs...\ze match limiting')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('f.*x\_.\+bar'), 'f•x•bar', 'regexp with . and \_.')
call vimtap#Is(ingo#regexp#deconstruct#ToQuasiLiteral('\%#=0\V\Cfoo\n\mbar'), "foo\nbar", 'regexp with \%#=0, \V\C\m')

call vimtest#Quit()
