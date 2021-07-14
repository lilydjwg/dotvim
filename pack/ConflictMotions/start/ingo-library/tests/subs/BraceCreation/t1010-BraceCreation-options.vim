" Test brace creation with options.

call vimtest#StartTap()
call vimtap#Plan(13)

function! s:Call( text, options )
    return ingo#subs#BraceCreation#FromSplitString(a:text, '', a:options)
endfunction

call vimtap#Is(s:Call('abc def zyz', {}), '{abc,def,zyz}', 'no common substrings')
call vimtap#Is(s:Call('abc def zyz', {'returnValueOnFailure' : ''}), '', 'no common substrings')
call vimtap#Is(s:Call('abc def zyz', {'returnValueOnFailure' : 'NO'}), 'NO', 'no common substrings')

call vimtap#Is(s:Call('FooHasBoo FooBoo FooBox', {}), 'Foo{Has,,}Bo{o,o,x}', 'optional inner default')
call vimtap#Is(s:Call('FooHasBoo FooBoo FooBox', {'optionalElementInSquareBraces': 1}), 'Foo[Has]Bo{o,o,x}', 'optional inner in square braces')
call vimtap#Is(s:Call('FooHasBoo FooBoo FooBox', {'uniqueElements': 1}), 'Foo{Has,}Bo{o,x}', 'unique')
call vimtap#Is(s:Call('FooHasBoo FooBoo FooBox', {'uniqueElements': 1, 'optionalElementInSquareBraces': 1}), 'Foo[Has]Bo{o,x}', 'unique and square braces')

call vimtap#Is(s:Call('fooHasBoo FOOBoo FooBox', {'optionalElementInSquareBraces': 1, 'isIgnoreCase': 1}), 'foo[Has]Bo{o,o,x}', 'case-insensitive optional inner in square braces')
call vimtap#Is(s:Call('addField field', {'optionalElementInSquareBraces': 1, 'isIgnoreCase': 1}), '[add]Field', 'case-insensitive optional end in square braces')

call vimtap#Is(s:Call('FooHasBoo FOOBoo FoOBox', {'short': 1}), 'Foo[Has]Bo{o,x}', 'short = unique and square braces and ignore-case')
call vimtap#Is(s:Call('FooHasBoo FOOBoo FoOBox', {'isIgnoreCase': 0, 'short': 1}), 'F{ooHas,OO,oO}Bo{o,x}', 'short without ignore-case')
call vimtap#Is(s:Call('FooHasBoo FOOBoo FoOBox', {'optionalElementInSquareBraces': 0, 'short': 1}), 'Foo{Has,}Bo{o,x}', 'short without optionalElementInSquareBraces')
call vimtap#Is(s:Call('FooHasBoo FOONoBoo FoONoBox', {'uniqueElements': 0, 'short': 1}), 'Foo{Has,No,No}Bo{o,o,x}', 'short without uniqueElements')

call vimtest#Quit()
