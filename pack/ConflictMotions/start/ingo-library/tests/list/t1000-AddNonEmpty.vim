" Test add non-empty items.

call vimtest#StartTap()
call vimtap#Plan(7)

let s:list = []
call vimtap#Is(ingo#list#AddNonEmpty(s:list, ''), [], 'Add empty String to empty List gives empty List')
call vimtap#Is(ingo#list#AddNonEmpty(s:list, []), [], 'Add empty List to empty List gives empty List')
call vimtap#Is(ingo#list#AddNonEmpty(s:list, ['']), [['']], 'Add List with empty String to empty List')
call vimtap#Is(ingo#list#AddNonEmpty(s:list, 42), [[''], 42], 'Add 42')
call vimtap#Is(ingo#list#AddNonEmpty(s:list, 'foobar'), [[''], 42, 'foobar'], 'Add foobar')

let s:originalList = s:list
call vimtap#Ok(ingo#list#AddNonEmpty(s:list, '') is# s:originalList, 'Add empty String to List gives same List')
call vimtap#Is(ingo#list#AddNonEmpty(s:list, [[]]), [[''], 42, 'foobar', [[]]], 'Add List with empty List')

call vimtest#Quit()
