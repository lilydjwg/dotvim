" Test brace creation.

function! s:Call( text )
    return ingo#subs#BraceCreation#FromSplitString(a:text, '', {'strict': 1})
endfunction

call vimtest#StartTap()
call vimtap#Plan(27)

call vimtap#Is(s:Call('fo! foX foo'), 'fo{!,X,o}', 'same prefix, different suffixes')
call vimtap#Is(s:Call('fox fooy foobar'), 'fo{x,oy,obar}', 'same prefix, different length suffixes')
call vimtap#Is(s:Call('myfoo theirfoo ourfoo'), '{my,their,our}foo', 'different prefixes, same suffix')
call vimtap#Is(s:Call('myfo! theirfoX ourfoo'), '{myfo!,theirfoX,ourfoo}', 'different prefixes, different suffixes')

call vimtap#Is(s:Call('foo1 foo2 foo3'), 'foo{1..3}', 'same prefix, number sequence')
call vimtap#Is(s:Call('foo1 foo2'), 'foo{1,2}', 'same prefix, short number sequence')
call vimtap#Is(s:Call('foo1 foo3 foo5'), 'foo{1..5..2}', 'same prefix, number sequence with offset')
call vimtap#Is(s:Call('foo1 foo3 foo5 fooX'), 'foo{{1..5..2},X}', 'same prefix, number sequence with offset and suffix')
call vimtap#Is(s:Call('foo1 foo3 foo5 fooX fooY'), 'foo{{1..5..2},X,Y}', 'same prefix, number sequence with offset and suffixes')
call vimtap#Is(s:Call('foo1 foo3 foo5 fooX fooY fooZ'), 'foo{{1..5..2},{X..Z}}', 'same prefix, number sequence with offset and char sequence')
call vimtap#Is(s:Call('foo1 foo3 foo5 fooX fooY fooZ foo10 foo20 foo30 foo40'), 'foo{{1..5..2},X,Y,Z,10,20,30,40}', 'same prefix, number sequence with offset and char sequence and another number sequence (only first detected)')
call vimtap#Is(s:Call('fooX fooY fooZ foo1 foo3 foo5'), 'foo{{X..Z},{1..5..2}}', 'same prefix, char sequence and number sequence (not detected)')

call vimtap#Is(s:Call('FooHasBoo FooIsBoo FooCanBoo'), 'Foo{Has,Is,Can}Boo', 'two commons in outside')
call vimtap#Is(s:Call('myFooHasBooHere theirFooIsBooNow ourFooCanBooMore'), '{myFooHasBooHere,theirFooIsBooNow,ourFooCanBooMore}', 'two commons in the middle')

call vimtap#Is(s:Call('foo,bar, fooxy'), 'foo{\,bar\,,xy}', 'embedded commas')
call vimtap#Is(s:Call('foobar foo{O} fooxy'), 'foo{bar,\{O\},xy}', 'embedded braces in one word')
call vimtap#Is(s:Call('foobar foo} foo{ fooxy'), 'foo{bar,\},\{,xy}', 'embedded braces in two words')

call vimtap#Is(s:Call('abc def zyz'), '{abc,def,zyz}', 'no common substrings')
call vimtap#Is(s:Call('abc abc abc'), 'abc', 'all common')

call vimtap#Is(s:Call('HasBooMe BooMe BoxMe'), '{HasBoo,Boo,Box}Me', 'same suffix, strict creation passes on inner common Bo')
call vimtap#Is(s:Call('FooHasBoo FooBoo FooBox'), 'Foo{HasBoo,Boo,Box}', 'same prefix, strict creation passes on inner common Bo')
call vimtap#Is(s:Call('FooHasBooMe FooBooMe FooBoxMe'), 'Foo{HasBoo,Boo,Box}Me', 'same prefix and suffix, strict creation passes on inner common Bo')
call vimtap#Is(s:Call('HasBoo Boo Box'), '{HasBoo,Boo,Box}', 'no same prefix nor suffix, strict creation passes on inner common Bo')

call vimtap#Is(s:Call('HasBooZeHereMe BooZeNowMe BoxZeMoreMe'), '{HasBooZeHere,BooZeNow,BoxZeMore}Me', 'same suffix, strict creation passes on inner commons Bo and Ze')
call vimtap#Is(s:Call('FooHasBooZeHere FooBooZeNow FooBoxZeMore'), 'Foo{HasBooZeHere,BooZeNow,BoxZeMore}', 'same prefix, strict creation passes on inner commons Bo and Ze')
call vimtap#Is(s:Call('FooHasBooZeHereMe FooBooZeNowMe FooBoxZeMoreMe'), 'Foo{HasBooZeHere,BooZeNow,BoxZeMore}Me', 'same prefix and suffix, strict creation passes on inner commons Bo and Ze')
call vimtap#Is(s:Call('HasBooZeHere BooZeNow BoxZeMore'), '{HasBooZeHere,BooZeNow,BoxZeMore}', 'no same prefix nor suffix, strict creation passes on inner commons Bo and Ze')

call vimtest#Quit()
