" Test estimation of invalid pattern.

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#err#Throws('PrefixGroupsSuffix: Unmatched \(', "call ingo#regexp#length#Project('my\\%(Foo\\|B\\(ar\\|il\\|ox\\|Fox\\)Trott')", 'missing closing paren throws exception')

call vimtest#Quit()
