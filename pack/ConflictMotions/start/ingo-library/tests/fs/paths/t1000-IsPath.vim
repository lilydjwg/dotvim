" Test check for path.

call vimtest#StartTap()
call vimtap#Plan(16)

call vimtap#Is(ingo#fs#path#IsPath(''), 0, 'empty String is not a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('foo.txt')), 0, 'foo.txt is not a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('./foo.txt')), 0, './foo.txt is not a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('../foo.txt')), 1, '../foo.txt is a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('./bar/foo.txt')), 1, './bar/foo.txt is a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('/bar')), 1, '/bar is a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('/bar/')), 1, '/bar/ is a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('/bar/foo.txt')), 1, '/bar/foo.txt is a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('bar/foo.txt')), 1, 'bar/foo.txt is a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('bar/../foo.txt')), 0, 'bar/../foo.txt is not a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('boo/bar/../foo.txt')), 1, 'boo/bar/../foo.txt is a path')

call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('C:/bar/foo.txt')), 1, 'C:/bar/foo.txt is a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('C:/')), 1, 'C:/ is a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('/')), 1, '/ is a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('..')), 1, '.. is a path')
call vimtap#Is(ingo#fs#path#IsPath(ingo#fs#path#Normalize('.')), 1, '. is a path')

call vimtest#Quit()
