" Test sorting dicts based on a priority attribute.

let s:one   = {'priority': 1, 'bar': 'first'}
let s:two   = {'priority': 2}
let s:three = {'priority': 3, 'bar': 'third'}
let s:objects = [s:two, s:three, s:one]

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#Is(sort(copy(s:objects), 'ingo#collections#PrioritySort'), [s:one, s:two, s:three], 'sorted based on priority')

call vimtest#Quit()
