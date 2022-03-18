" Test splitting into top-level branches.

call vimtest#StartTap()
call vimtap#Plan(13)

call vimtap#Is(ingo#regexp#split#TopLevelBranches(''), [''], 'empty pattern')
call vimtap#Is(ingo#regexp#split#TopLevelBranches('foo'), ['foo'], 'simple atom')
call vimtap#Is(ingo#regexp#split#TopLevelBranches('foo\|bar'), ['foo', 'bar'], 'single branch')
call vimtap#Is(ingo#regexp#split#TopLevelBranches('foo\|bar\|baz'), ['foo', 'bar', 'baz'], 'three-element single branch')
call vimtap#Is(ingo#regexp#split#TopLevelBranches('\%(foo\|bar\|baz\)'), ['\%(foo\|bar\|baz\)'], 'single branch wrapped in group')
call vimtap#Is(ingo#regexp#split#TopLevelBranches('\%(foo\|bar\|baz\)\|me'), ['\%(foo\|bar\|baz\)', 'me'], 'nested branch front')
call vimtap#Is(ingo#regexp#split#TopLevelBranches('me\|\%(foo\|bar\|baz\)'), ['me', '\%(foo\|bar\|baz\)'], 'nested branch back')
call vimtap#Is(ingo#regexp#split#TopLevelBranches('\(me\|you\)\|\%(foo\|bar\|baz\)'), ['\(me\|you\)', '\%(foo\|bar\|baz\)'], 'two nested branches')
call vimtap#Is(ingo#regexp#split#TopLevelBranches('me\|\%(foo\|b\%(i\|o\|ou\|ei\)r\|baz\)'), ['me', '\%(foo\|b\%(i\|o\|ou\|ei\)r\|baz\)'], 'multiply nested branches')

call vimtap#Is(ingo#regexp#split#TopLevelBranches('\|me\|\%(foo\|bar\|\|baz\)\|'), ['', 'me', '\%(foo\|bar\|\|baz\)', ''], 'empty branches')

call vimtap#Is(ingo#regexp#split#TopLevelBranches('(me|you)\|\%(foo)\|b)|r\)\|ga)'), ['(me|you)', '\%(foo)\|b)|r\)', 'ga)'], 'unescaped parenthese and bars')
call vimtap#Is(ingo#regexp#split#TopLevelBranches('me\|\%(foo\|b\%(i\|o\|ou\|ei\|r\|baz\)'), ['me', '\%(foo\|b\%(i\|o\|ou\|ei\|r\|baz\)'], 'missing closing parentheses')
call vimtap#Is(ingo#regexp#split#TopLevelBranches('me\|\%(foo\|b\%(i\|o\)\)\)\|ou\|ei\|r\|baz\)'), ['me', '\%(foo\|b\%(i\|o\)\)\)', 'ou', 'ei', 'r', 'baz\)'], 'too many closing parentheses')

call vimtest#Quit()
