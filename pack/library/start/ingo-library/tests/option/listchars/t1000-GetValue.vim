" Test getting listchars values.

set listchars=precedes:<,extends:>,tab:>-,trail:.,eol:$

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(ingo#option#listchars#GetValue('precedes'), '<', 'precedes element value')
call vimtap#Is(ingo#option#listchars#GetValue('tab'), '>-', 'tab element 2-character value')
call vimtap#Is(ingo#option#listchars#GetValue('eol'), '$', 'eol element value')
call vimtap#Is(ingo#option#listchars#GetValue('space'), '', 'space element missing value')
call vimtap#Is(ingo#option#listchars#GetValue('doesnotexist'), '', 'doesnotexist element missing value')

call vimtest#Quit()
