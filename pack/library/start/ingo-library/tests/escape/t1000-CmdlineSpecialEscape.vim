" Test escaping special cmdline characters.

call vimtest#StartTap()
call vimtap#Plan(7)

call vimtap#Is(ingo#escape#file#CmdlineSpecialEscape('foo'), 'foo', 'string without special characters is returned as-is')
call vimtap#Is(ingo#escape#file#CmdlineSpecialEscape('%'), '\%', 'standalone % gets escaped')
call vimtap#Is(ingo#escape#file#CmdlineSpecialEscape('this # and ##'), 'this \# and \#\#', '# and ## within a string get escaped')
call vimtap#Is(ingo#escape#file#CmdlineSpecialEscape('<cword>.txt'), '\<cword>.txt', '<cword> gets escaped')
call vimtap#Is(ingo#escape#file#CmdlineSpecialEscape('<other>'), '\<other>', '<other> gets escaped')

call vimtap#Is(ingo#escape#file#CmdlineSpecialEscape('foo/bar and foo\bar'), 'foo/bar and foo\bar', 'string without special characters but spaces and slashes is returned as-is')
call vimtap#Is(ingo#escape#file#CmdlineSpecialEscape('\% and % or \<this>'), '\% and \% or \<this>', 'already escaped stuff does not get escaped')

call vimtest#Quit()
