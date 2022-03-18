" Test AllMatches.

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(ingo#list#pattern#AllMatches(['foo', 'fox', 'fozzy'], 'o[^o]'), ['fox', 'fozzy'], 'return two matches')
call vimtap#Is(ingo#list#pattern#AllMatches(['foo', 'fox', 'fozzy'], 'noMatch'), [], 'no matches return empty List')

let s:list = ['foo', 'fox', 'fozzy']
let s:inputList = copy(s:list)
call ingo#list#pattern#AllMatches(s:inputList, 'o[^o]')
call vimtap#Is(s:inputList, s:list, 'the original List is left untouched')

call vimtest#Quit()
