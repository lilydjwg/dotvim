" Test splitting including separators.

call vimtest#StartTap()
call vimtap#Plan(8)

call vimtap#Is(ingo#collections#SplitKeepSeparators('foo-bar.baz.,.a;b;c.', '\A'), ['foo', '-', 'bar', '.', 'baz', '.', '', ',', '', '.', 'a', ';', 'b', ';', 'c', '.'], 'splitting on single non-alpha')
call vimtap#Is(ingo#collections#SplitKeepSeparators('foo-bar.baz.,.a;b;c.', '\A\+'), ['foo', '-', 'bar', '.', 'baz', '.,.', 'a', ';', 'b', ';', 'c', '.'], 'splitting on non-alphas')
call vimtap#Is(ingo#collections#SplitKeepSeparators('-foo-', '\A', 0), ['-', 'foo', '-'], 'omit first and last empty')
call vimtap#Is(ingo#collections#SplitKeepSeparators('-foo-', '\A', 1), ['', '-', 'foo', '-', ''], 'keep first and last empty')

call vimtap#Is(ingo#collections#SplitKeepSeparators('', '\A'), [], 'empty text')
call vimtap#Is(ingo#collections#SplitKeepSeparators('x', '\A'), ['x'], 'no separator')
call vimtap#Is(ingo#collections#SplitKeepSeparators('-', '\A', 0), ['-'], 'nokeep on separator only text')
call vimtap#Is(ingo#collections#SplitKeepSeparators('-', '\A', 1), ['', '-', ''], 'keep on separator only text')

call vimtest#Quit()
