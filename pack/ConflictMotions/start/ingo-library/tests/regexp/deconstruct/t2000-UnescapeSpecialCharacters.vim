" Test unescaping of special characters.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#regexp#deconstruct#UnescapeSpecialCharacters('foobar'), 'foobar', 'no special characters')
call vimtap#Is(ingo#regexp#deconstruct#UnescapeSpecialCharacters('^foo[bar]$'), '^foo[bar]$', 'keep regular atoms')

call vimtap#Is(ingo#regexp#deconstruct#UnescapeSpecialCharacters('\^foo\[bar\]\$'), '^foo[bar]$', 'literal ^[]$')
call vimtap#Is(ingo#regexp#deconstruct#UnescapeSpecialCharacters('f\~o\.\.\.b\*r'), 'f~o...b*r', 'literal ~.*')
call vimtap#Is(ingo#regexp#deconstruct#UnescapeSpecialCharacters('/foo\\bar\\\\'), '/foo\bar\\', 'literal \')

call vimtap#Is(ingo#regexp#deconstruct#UnescapeSpecialCharacters('\tfoo\r\nbar\e\e'), "\tfoo\r\nbar\e\e", 'special escape sequences')
call vimtap#Is(ingo#regexp#deconstruct#UnescapeSpecialCharacters('\~\~fox\bob\\ar\*\*'), "~~fox\bob\\ar**", 'literals and escape sequences')

call vimtest#Quit()
