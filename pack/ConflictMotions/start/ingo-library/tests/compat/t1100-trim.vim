" Test trim() compatibility.

call vimtest#SkipAndQuitIf(! exists('*trim'), 'Need support for trim')

source helpers/CompatChecker.vim
let g:IngoLibrary_CompatFor = 'trim'

call vimtest#StartTap()
call vimtap#Plan(6)

call IsCompatible('trim', 'trim on empty string', "")
call IsCompatible('trim', 'trim nothing', "some text")
call IsCompatible('trim', 'trim spaces', "   some text ")
call IsCompatible('trim', 'trim defaults', "  \r\t\t\r RESERVE \t\n\x0B\xA0")
call IsCompatible('trim', 'trim custom mask', "rm<Xrm<>X>rrm", "rm<>")
call IsCompatible('trim', 'trim spaces around non-ASCII text', "   \u222A\uFF4E\u30A7\u00E7\u00F8\u03B4\u0639\u3128\uC6C3\u8A9E ")

call vimtest#Quit()
