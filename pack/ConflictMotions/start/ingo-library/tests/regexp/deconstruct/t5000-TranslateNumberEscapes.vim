" Test translating numbered escapes.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#regexp#deconstruct#TranslateNumberEscapes('foobar'), 'foobar', 'no character classes')
call vimtap#Is(ingo#regexp#deconstruct#TranslateNumberEscapes('fo\%d120bar'), 'foxbar', 'decimal escape')
call vimtap#Is(ingo#regexp#deconstruct#TranslateNumberEscapes('fo\%o170bar'), 'foxbar', 'octal escape')
call vimtap#Is(ingo#regexp#deconstruct#TranslateNumberEscapes('fo\%x78bar\%x2e'), 'foxbar.', 'hex escapes')
call vimtap#Is(ingo#regexp#deconstruct#TranslateNumberEscapes('\%u20ac\%u269B'), "\u20ac\u269b", 'unicode BMP escapes')
call vimtap#Is(ingo#regexp#deconstruct#TranslateNumberEscapes('\%U1F4A5'), "\U1f4a5", 'unicode non-BMP escape')

call vimtest#Quit()
