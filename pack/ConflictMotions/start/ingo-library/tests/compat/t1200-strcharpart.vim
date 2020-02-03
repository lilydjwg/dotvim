" Test strcharpart() compatibility.

call vimtest#SkipAndQuitIf(! exists('*strcharpart'), 'Need support for strcharpart')

source helpers/CompatChecker.vim
let g:IngoLibrary_CompatFor = 'strcharpart'

call vimtest#StartTap()
call vimtap#Plan(5)

call IsCompatible('strcharpart', 'middle ASCII part with length', 'anASCIItext', 2, 5)
call IsCompatible('strcharpart', 'middle ASCII part without length', 'anASCIItext', 2)
call IsCompatible('strcharpart', 'middle Unicode part with length', 'an\u222A\uFF4E\u30A7\u00E7\u00F8\u03B4\u0639\u3128\uC6C3\u8A9Etext', 5, 4)
call IsCompatible('strcharpart', 'middle Unicode part without length', 'an\u222A\uFF4E\u30A7\u00E7\u00F8\u03B4\u0639\u3128\uC6C3\u8A9Etext', 5)

call IsCompatible('strcharpart', 'negative start', 'anASCIItext', -2, 5)

call vimtest#Quit()
