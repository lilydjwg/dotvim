" Test digesting various lists of strings.

call vimtest#StartTap()
call vimtap#Plan(11)

call vimtap#Is(ingo#digest#Get(
\   [
\       'foo-bar-baz',
\       'foo-boo-quux',
\   ], '\A'),
\   ['foo-'], 'Same first item')

call vimtap#Is(ingo#digest#Get(
\   [
\       'foo-bar-baz',
\       'fox-bar-quux',
\   ], '\A'),
\   ['-bar-'], 'Same second item')

call vimtap#Is(ingo#digest#Get(
\   [
\       'foo-bar-baz',
\       'fox-boo-baz',
\   ], '\A'),
\   ['-baz'], 'Same last item')

call vimtap#Is(ingo#digest#Get(
\   [
\       'foo-bar-baz',
\       'foo-boo-baz',
\   ], '\A'),
\   ['foo-', '-baz'], 'Same first and last items')

call vimtap#Is(ingo#digest#Get(
\   [
\       'foo-boo-baz',
\       'foo-boo-quux',
\   ], '\A'),
\   ['foo-boo-'], 'Same first and second items')

call vimtap#Is(ingo#digest#Get(
\   [
\       'foo-bar-baz',
\       'foo-boo-quux',
\       'foo-boo-baz',
\   ], '\A'),
\   ['foo-'], 'Same first item, less frequent other items')

call vimtap#Is(ingo#digest#Get(
\   [
\       'foo-bar-baz',
\       'foo-boo-quux',
\       'foo-boo-baz',
\   ], '\A', 67),
\   ['foo-'], 'Same first item, less frequent other items discarded by percentage')

call vimtap#Is(ingo#digest#Get(
\   [
\       'foo-bar-baz',
\       'foo-boo-quux',
\       'foo-boo-baz',
\   ], '\A', 50),
\   ['foo-boo-baz'], 'Same first item, less frequent other items accepted via percentage')


call vimtap#Is(ingo#digest#Get(
\   [
\       'a-long-list-of-various-stuff-and-so-see-here',
\       'the-long-list-has-various-things-in-here-and-nowhere',
\       'my-long-list-can-do-various-things-for-here-and-there',
\   ], '\A'),
\   ['-long-list-', '-various-', '-and-', 'here'], 'long list') " Note: 'here' loses its preceding separator because in other items is is grouped together with '-here-and-', so it's missing at that position.

call vimtap#Is(ingo#digest#Get(
\   [
\       'the-long-list-has-various-things-in-here-and-nowhere',
\       'a-long-list-of-various-stuff-and-so-see-here',
\       'my-long-list-can-do-various-things-for-here-and-there',
\   ], '\A'),
\   ['-long-list-', '-various-', '-here-and'], 'long list, different ordering')

call vimtap#Is(ingo#digest#Get(
\   [
\       'a-long-list-of-various-stuff-and-so-see-here',
\       'the-long-list-has-various-things-in-here-and-nowhere',
\       'my-long-list-can-do-various-things-for-here-and-there',
\   ], '\A', 60),
\   ['-long-list-', '-various-things-', '-here-and-'], 'long list with percentage')

call vimtest#Quit()
