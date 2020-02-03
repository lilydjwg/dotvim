" Test rendering listchar tab value with three characters.

call vimtest#SkipAndQuitIf(v:version < 801 || v:version == 801 && ! has('patch759'), 'Need support for three-character listchar tab setting')

set listchars=tab:<->,eol:$

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", 1), '<------><------>  some text<------>$', 'tab text rendered at end')

call vimtest#Quit()
