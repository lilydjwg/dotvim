" Test truncation with custom truncation indicator.

call vimtest#StartTap()
call vimtap#Plan(2)

let s:longFile = '/tmp/with/this/very/loooooong/path/in/there/before/filename.txt'
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 52, '/', ' - '), '/tmp/with/this/ - /path/in/there/before/filename.txt', 'drop three directories')
call vimtap#Is(ingo#fs#path#split#TruncateTo(s:longFile, 52, '/', '........'), '/tmp/with/this/......../in/there/before/filename.txt', 'drop four directories with long truncation indicator')

call vimtest#Quit()
