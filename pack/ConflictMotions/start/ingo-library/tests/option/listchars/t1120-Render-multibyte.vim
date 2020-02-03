" Test rendering listchar tab value with three characters.
scriptencoding utf-8

call vimtest#SkipAndQuitIf(&encoding !=# 'utf-8', 'Need Unicode encoding')

set listchars=precedes:<,extends:>,tab:»·,trail:¬,eol:¶,nbsp:×

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", 1), '»·······»·······  some text»·······¶', 'text rendered at end')

call vimtest#Quit()
