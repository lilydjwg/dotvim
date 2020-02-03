" Test rendering listchar values in text.

call vimtest#StartTap()
call vimtap#Plan(4)

set listchars=
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   ", 0),"\t\t  some text\th\xa0e\xa0r\xa0e   ", 'no change with empty listchars')
set listchars=precedes:<,extends:>,tab:>-,trail:.,eol:$
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   ", 0), ">------->-------  some text>-------h\xa0e\xa0r\xa0e   ", 'basic set rendered not at end')
set listchars+=nbsp:X
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   ", 0), '>------->-------  some text>-------hXeXrXe   ', 'full set rendered not at end')

call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   ", 1), '>------->-------  some text>-------hXeXrXe...$', 'full set rendered at end')

call vimtest#Quit()
