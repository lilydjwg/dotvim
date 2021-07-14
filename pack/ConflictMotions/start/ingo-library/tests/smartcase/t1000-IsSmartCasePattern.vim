" Test testing for smartcase pattern.

call vimtest#StartTap()
call vimtap#Plan(9)

call vimtap#Ok(ingo#smartcase#IsSmartCasePattern(ingo#smartcase#FromPattern('fooBar')), 'smartcase from fooBar')
call vimtap#Ok(ingo#smartcase#IsSmartCasePattern(ingo#smartcase#FromPattern('foo bar')), 'smartcase from foo bar')
call vimtap#Ok(ingo#smartcase#IsSmartCasePattern(ingo#smartcase#FromPattern('foo')), 'smartcase from foo')
call vimtap#Ok(ingo#smartcase#IsSmartCasePattern(ingo#smartcase#FromPattern('FOO')), 'smartcase from FOO')
call vimtap#Ok(ingo#smartcase#IsSmartCasePattern(ingo#smartcase#FromPattern('not one')), 'smartcase from FOO')

call vimtap#Ok(ingo#smartcase#IsSmartCasePattern('\cnot\A\=one'), 'smartcase: \cnot\A\=one')
call vimtap#Ok(! ingo#smartcase#IsSmartCasePattern('not one'), 'not smartcase: not one')
call vimtap#Ok(! ingo#smartcase#IsSmartCasePattern('\cnot one'), 'not smartcase: \cnot one')
call vimtap#Ok(! ingo#smartcase#IsSmartCasePattern('not\A\=one'), 'not smartcase: not\A\=one')

call vimtest#Quit()
