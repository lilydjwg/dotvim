" Test brace expansion with options.

call vimtest#StartTap()
call vimtap#Plan(2)

function! s:Call( text, options )
    return ingo#subs#BraceExpansion#ExpandToString(a:text, ' ', a:options)
endfunction

call vimtap#Is(s:Call('Foo{Has,}Bo{o,o,x}', {}), 'FooHasBoo FooHasBoo FooHasBox FooBoo FooBoo FooBox', 'optional inner in default curly braces')
call vimtap#Is(s:Call('Foo[Has]Bo{o,o,x}', {'optionalElementInSquareBraces': 1}), 'FooHasBoo FooHasBoo FooHasBox FooBoo FooBoo FooBox', 'optional inner in square braces')

call vimtest#Quit()
