" Test considering min or max length.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['abcd\+', 'abc\+', 'ab\+', 'a\+', '0*'], 'ooo'), ['abcd\+', 'abc\+', 'ooo', 'ab\+', 'a\+', '0*'], 'add ooo to staggered multis behind max=3')
call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['abcd\+', 'abc\+', 'ab\+', 'a\+', '0*'], 'ooo\+'), ['abcd\+', 'abc\+', 'ooo\+', 'ab\+', 'a\+', '0*'], 'add ooo\+ to staggered multis behind max=3')
call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['abcd\+', 'abc\+', 'ab\+', 'a\+', '0*'], 'o\{2,4}'), ['abcd\+', 'abc\+', 'ab\+', 'o\{2,4}', 'a\+', '0*'], 'add o\{2,4} to staggered multis behind max=2')

call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['a\{6,9}', 'b\{5,7}', 'c\{2,5}', 'd\{1,3}'], 'oooooo'), ['a\{6,9}', 'b\{5,7}', 'oooooo', 'c\{2,5}', 'd\{1,3}'], 'add ooooo to staged ranges')
call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['a\{6,9}', 'b\{5,7}', 'c\{2,5}', 'd\{1,3}'], 'o\{6}'), ['a\{6,9}', 'b\{5,7}', 'o\{6}', 'c\{2,5}', 'd\{1,3}'], 'add o\{6} to various ranges')
call vimtap#Is(ingo#regexp#split#AddPatternByProjectedMatchLength(['a\{6,9}', 'b\{5,7}', 'c\{2,5}', 'd\{1,3}'], 'o\{4,8}'), ['a\{6,9}', 'b\{5,7}', 'c\{2,5}', 'o\{4,8}', 'd\{1,3}'], 'o\{4,8} uses min to sort in max values')

call vimtest#Quit()
