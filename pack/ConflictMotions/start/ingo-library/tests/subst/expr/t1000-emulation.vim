" Test substition with replacement emulation.

function! s:IsEquivalent( expr, pat, sub, description )
    call vimtap#Is(ingo#subst#expr#emulation#Substitute(a:expr, a:pat, a:sub, ''), substitute(a:expr, a:pat, a:sub, ''), a:description)
    call vimtap#Is(ingo#subst#expr#emulation#Substitute(a:expr, a:pat, a:sub, 'g'), substitute(a:expr, a:pat, a:sub, 'g'), 'global ' . a:description)
endfunction

call vimtest#StartTap()
call vimtap#Plan(22)

call s:IsEquivalent('foobar', '[ao]', 'x', 'normal substitution')
call s:IsEquivalent('foobar', '[ao]', '\=toupper(submatch(0))', 'expression with submatch(0)')
call s:IsEquivalent('foobar', '\([ao]\)[ao]\?', '\=toupper(submatch(1))', 'expression with submatch(1)')
call s:IsEquivalent('this foo bar', '\<\(.\)\(.\)\(.\)\>', '\=submatch(3).submatch(2).submatch(2).submatch(1)', 'expression with many submatches')

call s:IsEquivalent('my foo your bar my baz your hihi', 'my \zs\<...\>', '\=toupper(submatch(0))', 'with \zs')
call s:IsEquivalent('my foo your bar my baz your hihi', '\<...\>\ze my', '\=toupper(submatch(0))', 'with \ze')
call s:IsEquivalent('my foo. your bar! my baz. your hihi.', 'my \zs\<...\>\ze[.!]', '\=toupper(submatch(0))', 'with \zs and \ze')

call s:IsEquivalent('foo can and foo cannot foo', '^foo\s', '\=toupper(submatch(0))', 'with ^ anchor')
call s:IsEquivalent('foo foo can and foo cannot foo', '^foo\s', '\=toupper(submatch(0))', 'with ^ anchor')
call s:IsEquivalent('foo can and foo cannot foo', '\sfoo$', '\=toupper(submatch(0))', 'with $ anchor')
call s:IsEquivalent('foo can and foo cannot foo foo', '\sfoo$', '\=toupper(submatch(0))', 'with $ anchor')

call vimtest#Quit()
