" Test brace creation.

call vimtest#StartTap()
call vimtap#Plan(21)

function! s:Call( text )
    return ingo#subs#BraceCreation#FromSplitString(a:text)
endfunction

call vimtap#Is(s:Call('fo! foX foo'), 'fo{!,X,o}', 'same prefix, different suffixes')
call vimtap#Is(s:Call('fox fooy foobar'), 'fo{x,oy,obar}', 'same prefix, different length suffixes')
call vimtap#Is(s:Call('myfoo theirfoo ourfoo'), '{my,their,our}foo', 'different prefixes, same suffix')
call vimtap#Is(s:Call('myfo! theirfoX ourfoo'), '{my,their,our}fo{!,X,o}', 'different prefixes, different suffixes')

call vimtap#Is(s:Call('foo1 foo2 foo3'), 'foo{1..3}', 'same prefix, number sequence')
call vimtap#Is(s:Call('foo1 foo2'), 'foo{1,2}', 'same prefix, short number sequence')
call vimtap#Is(s:Call('foo1 foo3 foo5'), 'foo{1..5..2}', 'same prefix, number sequence with offset')
call vimtap#Is(s:Call('foo1 foo3 foo5 fooX'), 'foo{{1..5..2},X}', 'same prefix, number sequence with offset and suffix')
call vimtap#Is(s:Call('foo1 foo3 foo5 fooX fooY'), 'foo{{1..5..2},X,Y}', 'same prefix, number sequence with offset and suffixes')
call vimtap#Is(s:Call('foo1 foo3 foo5 fooX fooY fooZ'), 'foo{{1..5..2},{X..Z}}', 'same prefix, number sequence with offset and char sequence')
call vimtap#Is(s:Call('foo1 foo3 foo5 fooX fooY fooZ foo10 foo20 foo30 foo40'), 'foo{{1..5..2},X,Y,Z,10,20,30,40}', 'same prefix, number sequence with offset and char sequence and another number sequence (only first detected)')
call vimtap#Is(s:Call('fooX fooY fooZ foo1 foo3 foo5'), 'foo{{X..Z},{1..5..2}}', 'same prefix, char sequence and number sequence (not detected)')

call vimtap#Is(s:Call('FooHasBoo FooIsBoo FooCanBoo'), 'Foo{Has,Is,Can}Boo', 'two commons in outside')
call vimtap#Is(s:Call('myFooHasBooHere theirFooIsBooNow ourFooCanBooMore'), '{my,their,our}Foo{Has,Is,Can}Boo{Here,Now,More}', 'two commons in the middle')

call vimtap#Is(s:Call('foo,bar, fooxy'), 'foo{\,bar\,,xy}', 'embedded commas')
call vimtap#Is(s:Call('foobar foo{O} fooxy'), 'foo{bar,\{O\},xy}', 'embedded braces in one word')
call vimtap#Is(s:Call('foobar foo} foo{ fooxy'), 'foo{bar,\},\{,xy}', 'embedded braces in two words')

call vimtap#Is(s:Call('abc def zyz'), '{abc,def,zyz}', 'no common substrings')
call vimtap#Is(s:Call('abc abc abc'), 'abc', 'all common')

call vimtap#Is(ingo#subs#BraceCreation#FromList(split('FooHasBoo FooIsBoo FooCanBoo', ' ')), 'Foo{Has,Is,Can}Boo', 'from list: two commons in outside')
call vimtap#Is(ingo#subs#BraceCreation#FromList(split('abc def zyz', ' ')), '{abc,def,zyz}', 'from list: no common substrings')

call vimtest#Quit()
