" Test recursive invocation of sub-replace-expression.

let g:IngoLibrary_CompatFor = 'RecursiveSubstitutionExpression'

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(ingo#compat#substitution#RecursiveSubstitutionExpression('foobor', 'o\+', 'X', 'g'), 'fXbXr', 'plain substitution')
call vimtap#Is(ingo#compat#substitution#RecursiveSubstitutionExpression('foobor', 'o\+', '\=repeat(submatch(0), 2)', 'g'), 'fooooboor', 'non-recursive expression substitution')
call vimtap#Is(substitute('foobor', '.o\+', '\=ingo#compat#substitution#RecursiveSubstitutionExpression(submatch(0), "^.", "\\=toupper(submatch(0))", "")', 'g'), 'FooBor', 'recursive expression substitution with inner compat function')
call vimtap#Is(ingo#compat#substitution#RecursiveSubstitutionExpression('foobor', '.o\+', '\=ingo#compat#substitution#RecursiveSubstitutionExpression(submatch(0), "^.", "\\=toupper(submatch(0))", "")', 'g'), 'FooBor', 'recursive expression substitution both using compat function')

function! Recurse() abort
    return ingo#compat#substitution#RecursiveSubstitutionExpression('yyy', '.\(.\).', '\=submatch(1) . submatch(1)', '')
endfunction
call vimtap#Is(substitute('foobor', 'o\+', '\=Recurse() . submatch(0)', 'g'), 'fyyoobyyor', 'recursive expression substitution through function')

call vimtest#Quit()
