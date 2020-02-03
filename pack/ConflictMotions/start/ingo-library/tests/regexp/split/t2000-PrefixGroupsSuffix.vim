" Test splitting prefix, group(s), suffix.

call vimtest#StartTap()
call vimtap#Plan(9)

call vimtap#Is(ingo#regexp#split#PrefixGroupsSuffix(''), [''], 'empty pattern')
call vimtap#Is(ingo#regexp#split#PrefixGroupsSuffix('foo'), ['foo'], 'simple literal pattern')
call vimtap#Is(ingo#regexp#split#PrefixGroupsSuffix('Foo\|Bar\|Fox'), ['Foo\|Bar\|Fox'], 'toplevel branches without group')

call vimtap#Is(ingo#regexp#split#PrefixGroupsSuffix('\%(Foo\|Bar\|Fox\)'), ['', 'Foo\|Bar\|Fox', ''], 'group with branches')
call vimtap#Is(ingo#regexp#split#PrefixGroupsSuffix('my\%(Foo\|Bar\|Fox\)Trott'), ['my', 'Foo\|Bar\|Fox', 'Trott'], 'group with branches inside literal prefix and suffix')
call vimtap#Is(ingo#regexp#split#PrefixGroupsSuffix('my\%(Foo\|Bar\|Fox\)In\(Our\|Their\)Trott'), ['my', 'Foo\|Bar\|Fox', 'In', 'Our\|Their', 'Trott'], 'two groups surrounded by literals')
call vimtap#Is(ingo#regexp#split#PrefixGroupsSuffix('\%(Foo\|Bar\|Fox\)\(Our\|Their\)'), ['', 'Foo\|Bar\|Fox', '', 'Our\|Their', ''], 'two groups unsurrounded')

call vimtap#Is(ingo#regexp#split#PrefixGroupsSuffix('my\%(Foo\|B\(ar\|il\|ox\)\|Fox\)Trott'), ['my', 'Foo\|B\(ar\|il\|ox\)\|Fox', 'Trott'], 'group with another group inside')
call vimtap#Is(ingo#regexp#split#PrefixGroupsSuffix('my\%(F\(al\)\?oo\|B\(ar\|il\|ox\)\|\(F\|\%(Var\)\?i\)ox\)Trott'), ['my', 'F\(al\)\?oo\|B\(ar\|il\|ox\)\|\(F\|\%(Var\)\?i\)ox', 'Trott'], 'group with other groups inside')

call vimtest#Quit()
