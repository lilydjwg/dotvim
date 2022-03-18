" Test parsing of collections.

call vimtest#StartTap()
call vimtap#Plan(6)

call vimtap#Is(substitute('f[^[:lower:]]oob[[:alpha:]]ar[[:space:][:xdigit:]]', ingo#regexp#collection#Expr(), '', 'g'), 'foobar', 'collection classes')

call vimtap#Is(substitute('f\k\kbar', ingo#regexp#collection#Expr(), '', 'g'), 'f\k\kbar', 'a character class')
call vimtap#Is(substitute('fo[abcopq]!', ingo#regexp#collection#Expr(), '', 'g'), 'fo!', 'simple collection')
call vimtap#Is(substitute('fo[[:alnum:]xyz][^a-z]!', ingo#regexp#collection#Expr(), '', 'g'), 'fo!', 'multiple collections')
call vimtap#Is(substitute('fo\_[abcopq]!', ingo#regexp#collection#Expr(), '', 'g'), 'fo!', 'collection including EOL')

call vimtap#Is(substitute('[[]foo[]]b[a]r[^!]', ingo#regexp#collection#Expr(), '', 'g'), 'foobr', 'single-literal collections')

call vimtest#Quit()
