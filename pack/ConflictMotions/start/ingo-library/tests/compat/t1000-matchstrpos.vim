" Test matchstrpos() compatibility.

call vimtest#SkipAndQuitIf(! exists('*matchstrpos'), 'Need support for matchstrpos')

source helpers/CompatChecker.vim
let g:IngoLibrary_CompatFor = 'matchstrpos'

call vimtest#StartTap()
call vimtap#Plan(12)

call IsCompatible('matchstrpos', 'string match', 'testing', 'ing')
call IsCompatible('matchstrpos', 'string not matching', 'testing', 'xxx')
call IsCompatible('matchstrpos', 'first match', 'testing', 't')

call IsCompatible('matchstrpos', 'start to second match', 'testing', 't', 3)
call IsCompatible('matchstrpos', 'start beyond matches', 'testing', 't', 7)

call IsCompatible('matchstrpos', 'string count 2', "testing", "..", 0, 2)


call IsCompatible('matchstrpos', 'List match', [1, '__x'], '\a')
call IsCompatible('matchstrpos', 'List not matching', [1, '__x'], 'xxx')

call IsCompatible('matchstrpos', 'List start to second match', ['foxy', 'foobar', 'foony', 'bar'], 'o', 1)
call IsCompatible('matchstrpos', 'List start beyond matches', ['foxy', 'foobar', 'foony', 'bar'], 'o', 3)

call IsCompatible('matchstrpos', 'List count 2', ['foxy', 'foobar', 'foony', 'bar'], 'o', 0, 2)
call IsCompatible('matchstrpos', 'List start to second, count 2', ['foony', 'faabar', 'fiiny', 'bar'], '\(.\)\1', 1, 2)

call vimtest#Quit()
