" Test removal of leading and trailing whitespace.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#str#Trim(''), '', 'no-op on empty string')
call vimtap#Is(ingo#str#Trim('foo bar'), 'foo bar', 'no surrounding whitespace, inner kept intact')
call vimtap#Is(ingo#str#Trim('  foo bar'), 'foo bar', 'remove just from front')
call vimtap#Is(ingo#str#Trim('foo bar  '), 'foo bar', 'remove just from back')
call vimtap#Is(ingo#str#Trim("\t\t    foo\tbar \t "), "foo\tbar", 'remove mixed surrounding whitespace')
call vimtap#Is(ingo#str#Trim("\n\nfoo\n\nbar\n"), "foo\n\nbar", 'remove surrounding newlines')

call vimtest#Quit()
