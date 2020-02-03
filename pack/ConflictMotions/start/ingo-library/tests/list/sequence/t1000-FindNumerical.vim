" Test find numerical sequences.

call vimtest#StartTap()
call vimtap#Plan(17)

call vimtap#Is(ingo#list#sequence#FindNumerical([]), [0, 0], 'empty list')
call vimtap#Is(ingo#list#sequence#FindNumerical([1]), [0, 0], 'single element list')

call vimtap#Is(ingo#list#sequence#FindNumerical([1, 2]), [2, 1], '1, 2 list')
call vimtap#Is(ingo#list#sequence#FindNumerical([2, 8]), [2, 6], '2, 8 list')
call vimtap#Is(ingo#list#sequence#FindNumerical([1, 2, 3]), [3, 1], '1, 2, 3 list')
call vimtap#Is(ingo#list#sequence#FindNumerical([2, 4, 6, 8]), [4, 2], '2, 4, 6, 8 list')
call vimtap#Is(ingo#list#sequence#FindNumerical([-2, -8]), [2, -6], '-2, -8 list')

call vimtap#Is(ingo#list#sequence#FindNumerical([1, 2, 4]), [2, 1], '1, 2 list with additional 4')
call vimtap#Is(ingo#list#sequence#FindNumerical([2, 4, 6, 8, 5, 10]), [4, 2], '2, 4, 6, 8 list with additional 5, 10')

call vimtap#Is(ingo#list#sequence#FindNumerical(['1', '2', '4']), [2, 1], 'String 1, 2 list with additional 4')
call vimtap#Is(ingo#list#sequence#FindNumerical(['1', '2', 'x']), [2, 1], 'String 1, 2 list with additional x')
call vimtap#Is(ingo#list#sequence#FindNumerical(['1', 2, '3']), [3, 1], 'String 1, number 2, string 3')
call vimtap#Is(ingo#list#sequence#FindNumerical(['1', '2', 'x', '3', '4']), [2, 1], 'String 1, 2 list with additional x 3 4 strings')
call vimtap#Is(ingo#list#sequence#FindNumerical(['a', 'b', 'c']), [0, 0], 'ascending single characters')
call vimtap#Is(ingo#list#sequence#FindNumerical(['foo', 'bar', 'cool']), [0, 0], 'various strings')
call vimtap#Is(ingo#list#sequence#FindNumerical(['1foo', '2bar', '3cool']), [0, 0], 'strings with prefixed numbers')
call vimtap#Is(ingo#list#sequence#FindNumerical(['010', '020', '040']), [2, 10], 'String 010, 020 list with additional 040, interpreted as decimal (not octal)')

call vimtest#Quit()
