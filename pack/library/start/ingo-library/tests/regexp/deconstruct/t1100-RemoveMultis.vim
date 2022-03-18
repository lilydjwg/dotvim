" Test removing multis.

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#regexp#deconstruct#RemoveMultis('foobar'), 'foobar', 'no multis')
call vimtap#Is(ingo#regexp#deconstruct#RemoveMultis('fo\{1,10}bar\? .* l\([aeiou]\)ll\1'), 'fobar . l\([aeiou]\)ll\1', '\? * \{} multis')
call vimtap#Is(ingo#regexp#deconstruct#RemoveMultis('fo\{-}ba\{-1}r\{-,10} \{2,7}x\\{1,2}'), 'fobar x\\{1,2}', 'various \{} multis')
call vimtap#Is(ingo#regexp#deconstruct#RemoveMultis('a\@<= foo\(bar\)\@=bar'), 'a foo\(bar\)bar', '\@= multis')

call vimtest#Quit()
