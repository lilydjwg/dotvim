" Test getting listchars values.

set listchars=precedes:<,extends:>,tab:>-,trail:.,eol:$

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#Is(ingo#option#listchars#GetValues(), {'precedes': '<', 'extends': '>', 'tab': '>-', 'trail': '.', 'eol': '$'}, 'listchars Dict')

call vimtest#Quit()
