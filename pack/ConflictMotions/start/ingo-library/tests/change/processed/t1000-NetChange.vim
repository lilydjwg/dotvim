" Test determining the net change.

call vimtest#StartTap()
call vimtap#Plan(4)

call vimtap#Is(ingo#change#processed#NetChange('foo bar'), 'foo bar', 'original text without backspaces is returned as-is')
call vimtap#Is(ingo#change#processed#NetChange("f\<BS>Foo\<BS>x"), 'Fox', 'two single backspaces are removed')
call vimtap#Is(ingo#change#processed#NetChange("f\<BS>Foo\<BS>\<BS>\<BS>Bas\<BS>r"), 'Bar', 'consecutive backspaces are removed')
call vimtap#Is(ingo#change#processed#NetChange("\<BS>\<BS>foo\<BS>x"), "\<BS>\<BS>fox", 'backspaces at the beginning are kept')

call vimtest#Quit()
