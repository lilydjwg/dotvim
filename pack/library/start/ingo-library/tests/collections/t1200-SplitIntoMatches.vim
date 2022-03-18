" Test splitting into matches.

call vimtest#StartTap()
call vimtap#Plan(9)

call vimtap#Is(ingo#collections#SplitIntoMatches('foo-bar.baz.,.a;b;c.', '\A'), ['-', '.', '.', ',', '.', ';', ';', '.'], 'splitting for single non-alpha')
call vimtap#Is(ingo#collections#SplitIntoMatches('foo-bar.baz.,.a;b;c.', '\A\+'), ['-', '.', '.,.', ';', ';', '.'], 'splitting for non-alphas')
call vimtap#Is(ingo#collections#SplitIntoMatches('-foo-', '\A'), ['-', '-'], 'start and end with match')

call vimtap#Is(ingo#collections#SplitIntoMatches('foo-bar.baz.,.a;b;c.', '\a'), ['f', 'o', 'o', 'b', 'a', 'r', 'b', 'a', 'z', 'a', 'b', 'c'], 'splitting for single alpha')
call vimtap#Is(ingo#collections#SplitIntoMatches('foo-bar.baz.,.a;b;c.', '\a\+'), ['foo', 'bar', 'baz', 'a', 'b', 'c'], 'splitting for alphas')

call vimtap#Is(ingo#collections#SplitIntoMatches('', '\A'), [], 'empty text')
call vimtap#Is(ingo#collections#SplitIntoMatches('x', '\A'), [], 'no separator')
call vimtap#Is(ingo#collections#SplitIntoMatches('-', '\A', 0), ['-'], 'nokeep on separator only text')
call vimtap#Is(ingo#collections#SplitIntoMatches('-', '\A', 1), ['-'], 'keep on separator only text')

call vimtest#Quit()
