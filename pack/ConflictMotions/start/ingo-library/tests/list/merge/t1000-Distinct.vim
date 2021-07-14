" Test merging of distinct Lists.

call vimtest#StartTap()
call vimtap#Plan(14)

call vimtap#Is(ingo#list#merge#Distinct([]), [], 'Merge of single empty list')
call vimtap#Is(ingo#list#merge#Distinct([], []), [], 'Merge of two empty lists')

call vimtap#Is(ingo#list#merge#Distinct([1], [0]), [1], 'Merge of two one-element lists')
call vimtap#Is(ingo#list#merge#Distinct([0], [1]), [1], 'Merge of two one-element lists in the other order')
call vimtap#Is(ingo#list#merge#Distinct([0], [0], [1], [0]), [1], 'Merge of four one-element lists')

call vimtap#Is(ingo#list#merge#Distinct([1, 0, 0], [0, 2, 3]), [1, 2, 3], 'Merge of two three-element distinct lists')
call vimtap#Is(ingo#list#merge#Distinct([0, 0, 3], [1, 0, 0], [0, 2, 0]), [1, 2, 3], 'Merge of three three-element distinct lists')

call vimtap#Is(ingo#list#merge#Distinct([1, 0, 0], ['', 'foo', ''], [[], [], ['hi', 'ho']]), [1, 'foo', ['hi', 'ho']], 'Merge of three three-element distinct lists of numbers, strings, and Lists')

call vimtap#Is(ingo#list#merge#Distinct([0, 0, 3], [1], [0, 2]), [1, 2, 3], 'Merge of three three-element distinct lists of unequal length')
call vimtap#Is(ingo#list#merge#Distinct([], [0, 0, 3], [], [1], [0, 2]), [1, 2, 3], 'Merge of five three-element distinct lists of unequal length')

call vimtap#Is(ingo#list#merge#Distinct([0, 0, 3], [1, 0, 0], [0, 0, 0]), [1, 0, 3], 'Merge of three three-element distinct lists with non-empty second element')
call vimtap#Is(ingo#list#merge#Distinct([0, [], 3], [1, 0, 0], [0, '', 0]), [1, [], 3], 'Merge of three three-element distinct lists with non-empty second element takes it from the first list')

call vimtap#err#Throws('Distinct: Multiple non-empty values at index 0', 'call ingo#list#merge#Distinct([1], [1])', 'Merge of two one-element lists with both non-empty values throws exception')
call vimtap#err#Throws('Distinct: Multiple non-empty values at index 3', 'call ingo#list#merge#Distinct([1, 0, 0, 42, 0], [0, 2, 3, 44, 5])', 'Merge of two five-element lists with both non-empty values throws exception')

call vimtest#Quit()
