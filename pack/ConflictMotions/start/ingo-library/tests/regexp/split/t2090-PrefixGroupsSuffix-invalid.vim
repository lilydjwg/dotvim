" Test splitting prefix, group(s), suffix of invalid pattern.

call vimtest#StartTap()
call vimtap#Plan(2)

call vimtap#err#Throws('PrefixGroupsSuffix: Unmatched \(', "call ingo#regexp#split#PrefixGroupsSuffix('my\\%(Foo\\|B\\(ar\\|il\\|ox\\|Fox\\)Trott')", 'missing closing paren throws exception')
call vimtap#err#Throws('PrefixGroupsSuffix: Unmatched \)', "call ingo#regexp#split#PrefixGroupsSuffix('my\\%(Foo\\|B\\(ar\\|il\\)\\|ox\\)\\|Fox\\)Trott')", 'missing opening paren throws exception')

call vimtest#Quit()
