" Test translating branches.

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#regexp#deconstruct#TranslateBranches('foobar'), 'foobar', 'no group')
call vimtap#Is(ingo#regexp#deconstruct#TranslateBranches('\\(foo(bar)\\)'), '\\(foo(bar)\\)', 'no group')
call vimtap#Is(ingo#regexp#deconstruct#TranslateBranches('my\(foo\|bar\)z'), 'my(foo|bar)z', 'translate capture group')
call vimtap#Is(ingo#regexp#deconstruct#TranslateBranches('my\%(fo\(o\|u\|xy\)\|bar\)z'), 'my(fo(o|u|xy)|bar)z', 'translate mixed nested groups')

call vimtest#Quit()
