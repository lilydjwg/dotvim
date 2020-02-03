" Test brace expansion of sequences.

function! s:Call( text )
    return join(ingo#subs#BraceExpansion#ExpandStrict(a:text), ' ')
endfunction

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(s:Call('foo{1..10}'), 'foo1 foo2 foo3 foo4 foo5 foo6 foo7 foo8 foo9 foo10', 'same prefix, number sequence')
call vimtap#Is(s:Call('foo{01..10}'), 'foo01 foo02 foo03 foo04 foo05 foo06 foo07 foo08 foo09 foo10', 'same prefix, 0-padded start number')
call vimtap#Is(s:Call('foo{001..10}'), 'foo001 foo002 foo003 foo004 foo005 foo006 foo007 foo008 foo009 foo010', 'same prefix, 00-padded start number')
call vimtap#Is(s:Call('foo{1..010}'), 'foo001 foo002 foo003 foo004 foo005 foo006 foo007 foo008 foo009 foo010', 'same prefix, 0-padded end number')
call vimtap#Is(s:Call('foo{01..010}'), 'foo001 foo002 foo003 foo004 foo005 foo006 foo007 foo008 foo009 foo010', 'same prefix, 0-padded start and end number')
call vimtap#Is(s:Call('foo{00..100..010}'), 'foo000 foo010 foo020 foo030 foo040 foo050 foo060 foo070 foo080 foo090 foo100', 'same prefix, 00-padded start number, 0-padded step')

call vimtest#Quit()

