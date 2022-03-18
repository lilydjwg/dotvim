" Test remove trailing text

call vimtest#StartTap()
call vimtap#Plan(13)

call vimtap#Is(ingo#str#remove#Leading('foobar', 'foo'), 'bar', 'remove foo from foobar')
call vimtap#Is(ingo#str#remove#Leading('foo', 'foo'), '', 'remove foo from foo')
call vimtap#Is(ingo#str#remove#Leading('oo', 'foo'), 'oo', 'remove foo from oo')
call vimtap#Is(ingo#str#remove#Leading('fo', 'foo'), 'fo', 'remove foo from fo')
call vimtap#Is(ingo#str#remove#Leading('f', 'foo'), 'f', 'remove foo from f')
call vimtap#Is(ingo#str#remove#Leading('', 'foo'), '', 'remove foo from empty string')
call vimtap#Is(ingo#str#remove#Leading('foo', ''), 'foo', 'remove empty string from foo')
call vimtap#Is(ingo#str#remove#Leading('foobar', '...'), 'foobar', 'remove ... from foobar')

call vimtap#Is(ingo#str#remove#Leading('foobar', 'fxo'), 'foobar', 'ignore non-matching prefix by default')
call vimtap#Is(ingo#str#remove#Leading('foobar', 'fxo', 'ignore'), 'foobar', 'ignore non-matching prefix with ignore')
call vimtap#Is(ingo#str#remove#Leading('foobar', 'fxo', 'nocheck'), 'bar', 'remove non-matching prefix with nocheck')
call vimtap#err#Throws('Leading: "foobar" does not start with "fxo"', "call ingo#str#remove#Leading('foobar', 'fxo', 'throw')", 'exception on non-matching prefix with throw')
call vimtap#err#Throws('ASSERT: Invalid errorStrategy: doesNotExist', "call ingo#str#remove#Leading('foobar', 'fxo', 'doesNotExist')", 'assertion failure on invalid errorStrategy')

call vimtest#Quit()
