" Test completely splitting into matches.

call vimtest#StartTap()
call vimtap#Plan(10)

call vimtap#Is(ingo#collections#SplitIntoMatches('foo-bar.baz.,.a;b;c.', '\a\+\A\+', ''), ['foo-', 'bar.', 'baz.,.', 'a;', 'b;', 'c.'], 'splitting for alphas-non-alphas')
call vimtap#err#Throws("SplitIntoMatches: Cannot discard 'c'", "call ingo#collections#SplitIntoMatches('foo-bar.baz.,.a;b;c', '\\a\\+\\A\\+', '')", 'exception thrown')

call vimtap#Is(ingo#collections#SplitIntoMatches('foo-bar!baz', '\a\+', '[^.;?]'), ['foo', 'bar', 'baz'], 'splitting for alphas-non-alpha')
call vimtap#err#Throws("SplitIntoMatches: Cannot discard '.'", "call ingo#collections#SplitIntoMatches('foo-bar.baz', '\\a\\+', '[^.;?]')", 'exception thrown')
call vimtap#err#Throws("SplitIntoMatches: Cannot discard '.'", "call ingo#collections#SplitIntoMatches('foo-bar.baz', '\\a\\+', '-')", 'exception thrown')

call vimtap#Is(ingo#collections#SplitIntoMatches('foo-bar.baz.,.a;b;c.', '\a\+\A\+', '^$'), ['foo-', 'bar.', 'baz.,.', 'a;', 'b;', 'c.'], 'splitting for alphas-non-alphas with ^$')
call vimtap#Is(ingo#collections#SplitIntoMatches('foo-bar.baz.,.a;b;c.', '\a\+\A', '\A\{0,2\}'), ['foo-', 'bar.', 'baz.', 'a;', 'b;', 'c.'], 'splitting for alphas-non-alphas with ^$')

call vimtap#err#Throws("SplitIntoMatches: Cannot discard '.,.'", "call ingo#collections#SplitIntoMatches('foo-bar.baz.,.a;b;c.', '\\a\\+', '\\A\\?')", 'exception thrown')

call vimtap#Is(ingo#collections#SplitIntoMatches('foobarbaz', '...', ''), ['foo', 'bar', 'baz'], 'splitting into three-char groups')
call vimtap#err#Throws("SplitIntoMatches: Cannot discard 'xy'", "call ingo#collections#SplitIntoMatches('foobarquuxy', '...', '')", 'exception thrown')

call vimtest#Quit()
