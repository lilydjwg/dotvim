" Test remove trailing text

call vimtest#StartTap()
call vimtap#Plan(13)

call vimtap#Is(ingo#str#remove#Trailing('foobar', 'bar'), 'foo', 'remove bar from foobar')
call vimtap#Is(ingo#str#remove#Trailing('foo', 'foo'), '', 'remove foo from foo')
call vimtap#Is(ingo#str#remove#Trailing('oo', 'foo'), 'oo', 'remove foo from oo')
call vimtap#Is(ingo#str#remove#Trailing('fo', 'foo'), 'fo', 'remove foo from fo')
call vimtap#Is(ingo#str#remove#Trailing('f', 'foo'), 'f', 'remove foo from f')
call vimtap#Is(ingo#str#remove#Trailing('', 'foo'), '', 'remove foo from empty string')
call vimtap#Is(ingo#str#remove#Trailing('foo', ''), 'foo', 'remove empty string from foo')
call vimtap#Is(ingo#str#remove#Trailing('foobar', '...'), 'foobar', 'remove ... from foobar')

call vimtap#Is(ingo#str#remove#Trailing('foobar', 'bxr'), 'foobar', 'ignore non-matching suffix by default')
call vimtap#Is(ingo#str#remove#Trailing('foobar', 'bxr', 'ignore'), 'foobar', 'ignore non-matching suffix with ignore')
call vimtap#Is(ingo#str#remove#Trailing('foobar', 'bxr', 'nocheck'), 'foo', 'remove non-matching suffix with nocheck')
call vimtap#err#Throws('Trailing: "foobar" does not end with "bxr"', "call ingo#str#remove#Trailing('foobar', 'bxr', 'throw')", 'exception on non-matching suffix with throw')
call vimtap#err#Throws('ASSERT: Invalid errorStrategy: doesNotExist', "call ingo#str#remove#Trailing('foobar', 'bxr', 'doesNotExist')", 'assertion failure on invalid errorStrategy')

call vimtest#Quit()
