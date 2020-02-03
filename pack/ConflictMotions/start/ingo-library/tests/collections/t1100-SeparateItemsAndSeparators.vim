" Test splitting into two Lists.

call vimtest#StartTap()
call vimtap#Plan(8)

call vimtap#Is(ingo#collections#SeparateItemsAndSeparators('foo-bar.baz.,.a;b;c.', '\A'), [['foo', 'bar', 'baz', '', '', 'a', 'b', 'c'], ['-', '.', '.', ',', '.', ';', ';', '.']], 'splitting on single non-alpha')
call vimtap#Is(ingo#collections#SeparateItemsAndSeparators('foo-bar.baz.,.a;b;c.', '\A\+'), [['foo', 'bar', 'baz', 'a', 'b', 'c'], ['-', '.', '.,.', ';', ';', '.']], 'splitting on non-alphas')
call vimtap#Is(ingo#collections#SeparateItemsAndSeparators('-foo-', '\A', 0), [['foo'], ['-', '-']], 'omit first and last empty')
call vimtap#Is(ingo#collections#SeparateItemsAndSeparators('-foo-', '\A', 1), [['', 'foo', ''], ['-', '-']], 'keep first and last empty')

call vimtap#Is(ingo#collections#SeparateItemsAndSeparators('', '\A'), [[], []], 'empty text')
call vimtap#Is(ingo#collections#SeparateItemsAndSeparators('x', '\A'), [['x',], []], 'no separator')
call vimtap#Is(ingo#collections#SeparateItemsAndSeparators('-', '\A', 0), [[], ['-']], 'nokeep on separator only text')
call vimtap#Is(ingo#collections#SeparateItemsAndSeparators('-', '\A', 1), [['', ''], ['-']], 'keep on separator only text')

call vimtest#Quit()
