" Test removal of trailing whitespace.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#str#TrimTrailing(''), '', 'no-op on empty string')
call vimtap#Is(ingo#str#TrimTrailing('foo bar'), 'foo bar', 'no surrounding whitespace, inner kept intact')
call vimtap#Is(ingo#str#TrimTrailing('  foo bar'), '  foo bar', 'remove nothing from front')
call vimtap#Is(ingo#str#TrimTrailing('foo bar  '), 'foo bar', 'remove from back')
call vimtap#Is(ingo#str#TrimTrailing("\t\t    foo\tbar \t "), "\t\t    foo\tbar", 'remove mixed trailing whitespace')
call vimtap#Is(ingo#str#TrimTrailing("\n\nfoo\n\nbar\n"), "\n\nfoo\n\nbar", 'remove trailing newlines')

call vimtest#Quit()
