" Test reading a non-existing file.

call vimtest#StartTap()
call vimtap#Plan(1)

call vimtap#Is(ingo#file#GetLines('doesnotexist.txt'), [], 'Get non-existing file returns empty List')

call vimtest#Quit()
