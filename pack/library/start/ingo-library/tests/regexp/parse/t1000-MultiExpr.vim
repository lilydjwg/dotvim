" Test parsing of multis.

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(substitute('foobar', ingo#regexp#parse#MultiExpr(), '', 'g'), 'foobar', 'no multis')
call vimtap#Is(substitute('fo*bar', ingo#regexp#parse#MultiExpr(), '', 'g'), 'fobar', '* multi')
call vimtap#Is(substitute('fo\{1,10}', ingo#regexp#parse#MultiExpr(), '', 'g'), 'fo', '\{} multi')
call vimtap#Is(substitute('fo\{-}ba\{-1}r\{-,10} \{2,7}x\\{1,2}', ingo#regexp#parse#MultiExpr(), '', 'g'), 'fobar x\\{1,2}', 'various \{} multis')
call vimtap#Is(substitute('a\@<= foo\(bar\)\@=bar', ingo#regexp#parse#MultiExpr(), '', 'g'), 'a foo\(bar\)bar', '\@= multis')

call vimtest#Quit()
