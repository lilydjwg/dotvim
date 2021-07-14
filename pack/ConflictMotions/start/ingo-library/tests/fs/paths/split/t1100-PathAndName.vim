" Test splitting filespec into path and name.

call vimtest#StartTap()
call vimtap#Plan(20)

call vimtap#Is(ingo#fs#path#split#PathAndName(''), ['./', ''], 'split empty filespec')
call vimtap#Is(ingo#fs#path#split#PathAndName('./foo.txt'), ['./', 'foo.txt'], 'split ./foo.txt')
call vimtap#Is(ingo#fs#path#split#PathAndName('../foo.txt'), ['../', 'foo.txt'], 'split ../foo.txt')
call vimtap#Is(ingo#fs#path#split#PathAndName('./bar/foo.txt'), ['./bar/', 'foo.txt'], 'split ./bar/foo.txt')
call vimtap#Is(ingo#fs#path#split#PathAndName('/bar'), ['/', 'bar'], 'split /bar')
call vimtap#Is(ingo#fs#path#split#PathAndName('/bar/'), ['/bar/', ''], 'split /bar/')
call vimtap#Is(ingo#fs#path#split#PathAndName('/bar/foo.txt'), ['/bar/', 'foo.txt'], 'split /bar/foo.txt')
call vimtap#Is(ingo#fs#path#split#PathAndName('bar/foo.txt'), ['bar/', 'foo.txt'], 'split bar/foo.txt')
call vimtap#Is(ingo#fs#path#split#PathAndName('bar/../foo.txt'), ['bar/../', 'foo.txt'], 'split bar/../foo.txt')
call vimtap#Is(ingo#fs#path#split#PathAndName('boo/bar/../foo.txt'), ['boo/bar/../', 'foo.txt'], 'split boo/bar/../foo.txt')

call vimtap#Is(ingo#fs#path#split#PathAndName('C:/bar/foo.txt'), ['C:/bar/', 'foo.txt'], 'split C:/bar/foo.txt')
call vimtap#Is(ingo#fs#path#split#PathAndName('C:/'), ['C:/', ''], 'split C:/')
call vimtap#Is(ingo#fs#path#split#PathAndName('/'), ['/', ''], 'split /')
call vimtap#Is(ingo#fs#path#split#PathAndName('..'), ['../', ''], 'split ..')
call vimtap#Is(ingo#fs#path#split#PathAndName('.'), ['./', ''], 'split .')

call vimtap#Is(ingo#fs#path#split#PathAndName('', 0), ['.', ''], 'split empty filespec without trailing separator')
call vimtap#Is(ingo#fs#path#split#PathAndName('/bar/foo.txt', 0), ['/bar', 'foo.txt'], 'split /bar/foo.txt without trailing separator')
call vimtap#Is(ingo#fs#path#split#PathAndName('/bar', 0), ['/', 'bar'], 'split /bar without trailing separator')
call vimtap#Is(ingo#fs#path#split#PathAndName('..', 0), ['..', ''], 'split .. without trailing separator')
call vimtap#Is(ingo#fs#path#split#PathAndName('.', 0), ['.', ''], 'split . without trailing separator')

call vimtest#Quit()
