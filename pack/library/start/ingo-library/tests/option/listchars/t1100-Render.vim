" Test rendering listchar values in text.

call vimtest#StartTap()
call vimtap#Plan(12)

set listchars=
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   ", 0),"\t\t  some text\th\xa0e\xa0r\xa0e   ", 'no change with empty listchars, no end (deprecated)')
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   "),"\t\t  some text\th\xa0e\xa0r\xa0e   ", 'no change with empty listchars')
set listchars=precedes:<,extends:>,tab:>-,trail:.,eol:$
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   ", 0), ">------->-------  some text>-------h\xa0e\xa0r\xa0e   ", 'basic set rendered not at end, no end (deprecated)')
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   "), ">------->-------  some text>-------h\xa0e\xa0r\xa0e   ", 'basic set rendered not at end')
set listchars+=nbsp:X
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   ", 0), '>------->-------  some text>-------hXeXrXe   ', 'full set rendered not at end, no end (deprecated)')
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   "), '>------->-------  some text>-------hXeXrXe   ', 'full set rendered not at end')

call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   ", 1), '>------->-------  some text>-------hXeXrXe...$', 'full set rendered at end (deprecated)')
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   ", {'isTextAtEnd': 1}), '>------->-------  some text>-------hXeXrXe...$', 'full set rendered at end')

set listchars+=space:!
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\th\xa0e\xa0r\xa0e   ", {'isTextAtEnd': 1}), '>------->-------!!some!text>-------hXeXrXe...$', 'full set and space rendered at end')

call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", {'isTextAtEnd': 1}), '>------->-------!!some!text>-------$', 'tab text')
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", {'isTextAtEnd': 1, 'tabWidth': 4}), '>--->---!!some!text>---$', 'tab text with shorter tab width 4')
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", {'isTextAtEnd': 1, 'tabWidth': 1}), '>>!!some!text>$', 'tab text with tab width 1')

call vimtest#Quit()
