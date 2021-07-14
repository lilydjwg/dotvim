" Test parsing of groups and branches.

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(substitute('foobar', ingo#regexp#parse#GroupBranchExpr(), '', 'g'), 'foobar', 'no branches')
call vimtap#Is(substitute('foo\(bar\)', ingo#regexp#parse#GroupBranchExpr(), '', 'g'), 'foobar', 'captured group')
call vimtap#Is(substitute('\%(x\)', ingo#regexp#parse#GroupBranchExpr(), '', 'g'), 'x', 'non-capturing group')
call vimtap#Is(substitute('foo\|bar', ingo#regexp#parse#GroupBranchExpr(), '', 'g'), 'foobar', 'branch')
call vimtap#Is(substitute('|(f)\|oo\(b\%(a\|u\+\)r\)', ingo#regexp#parse#GroupBranchExpr(), '', 'g'), '|(f)oobau\+r', 'complex branches and nested groups')

call vimtest#Quit()
