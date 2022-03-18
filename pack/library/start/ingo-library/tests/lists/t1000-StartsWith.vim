" Test StartsWith.

call vimtest#StartTap()
call vimtap#Plan(11)

call vimtap#Is(ingo#lists#StartsWith([1, 2, 3], []), 1, 'list starts with empty sublist')
call vimtap#Is(ingo#lists#StartsWith([1, 2, 3], [1]), 1, 'list starts with same first element')
call vimtap#Is(ingo#lists#StartsWith([1, 2, 3], [1, 2]), 1, 'list starts with same first elements')
call vimtap#Is(ingo#lists#StartsWith([1, 2, 3], [1, 2, 3]), 1, 'list is identical with sublist')
call vimtap#Is(ingo#lists#StartsWith([1, 2, 3], [1, 9]), 0, 'sublist differs in second element')
call vimtap#Is(ingo#lists#StartsWith([1, 2, 3], [1, 2, 3, 4]), 0, 'sublist has more elements than list')
call vimtap#Is(ingo#lists#StartsWith([1, 2, 3], [9, 7, 5]), 0, 'sublist has different elements')
call vimtap#Is(ingo#lists#StartsWith([1, 2, 3], ['a']), 0, 'sublist has different elements')

call vimtap#Is(ingo#lists#StartsWith(['a', 'b', 'c'], ['a', 'b'], 0), 1, 'case-sensistive comparison with identical cases')
call vimtap#Is(ingo#lists#StartsWith(['a', 'b', 'c'], ['a', 'B'], 0), 0, 'case-sensistive comparison with different case in second element')
call vimtap#Is(ingo#lists#StartsWith(['a', 'b', 'c'], ['a', 'B'], 1), 1, 'case-insensistive comparison with different case in second element')

call vimtest#Quit()
