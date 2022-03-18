" Test rendering listchar tab value with three characters.

call vimtest#SkipAndQuitIf(v:version < 801 || v:version == 801 && ! has('patch759'), 'Need support for three-character listchar tab setting')

set listchars=tab:<->,eol:$

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", {'isTextAtEnd': 1}), '<------><------>  some text<------>$', 'tab text rendered at end')
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", {'isTextAtEnd': 1, 'tabWidth': 4}), '<--><-->  some text<-->$', 'tab text with shorter tab width 4')
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", {'isTextAtEnd': 1, 'tabWidth': 3}), '<-><->  some text<->$', 'tab text with shorter tab width 3')
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", {'isTextAtEnd': 1, 'tabWidth': 2}), '<><>  some text<>$', 'tab text with tab width 2')
call vimtap#Is(ingo#option#listchars#Render("\t\t  some text\t", {'isTextAtEnd': 1, 'tabWidth': 1}), '>>  some text>$', 'tab text with tab width 1')

call vimtest#Quit()
