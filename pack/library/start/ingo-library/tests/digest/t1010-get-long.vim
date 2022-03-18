" Test digesting long lists of strings.

call vimtest#StartTap()
call vimtap#Plan(3)

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
