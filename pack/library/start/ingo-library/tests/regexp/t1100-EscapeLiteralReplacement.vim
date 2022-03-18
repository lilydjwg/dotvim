" Test literal replacement.

call vimtest#StartTap()
call vimtap#Plan(5)

call vimtap#Is(substitute('foo', 'o', ingo#regexp#EscapeLiteralReplacement('A\O'), 'g'), 'fA\OA\O', 'substitute() of backslash')
call vimtap#Is(substitute('foo', 'o', ingo#regexp#EscapeLiteralReplacement('A&O'), 'g'), 'fA&OA&O', 'substitute() of &')
call vimtap#Is(substitute('foo', 'o', ingo#regexp#EscapeLiteralReplacement('A~O'), 'g'), 'fA~OA~O', 'substitute() of ~')
call vimtap#Is(substitute('foo', 'o', ingo#regexp#EscapeLiteralReplacement('A/~&\O', ''), 'g'), 'fA/~&\OA/~&\O', 'substitute() with (wrong) empty optional argument')

call setline(1, repeat(['foo'], 5))
execute '1substitute/o/' . ingo#regexp#EscapeLiteralReplacement("A\\O", '/') . '/g'
execute '2substitute#o#' . ingo#regexp#EscapeLiteralReplacement("#A\\O", '#') . '#g'
execute '3substitute/o/' . ingo#regexp#EscapeLiteralReplacement("/\\1&\\", '/') . '/g'
execute '4substitute/o/' . ingo#regexp#EscapeLiteralReplacement("/&~\\", '/') . '/g'
set nomagic
execute '5substitute/o/' . ingo#regexp#EscapeLiteralReplacement("/&~\\", '/') . '/g'
call vimtap#Is(substitute('foo', 'o', ingo#regexp#EscapeLiteralReplacement('A/~&\O', ''), 'g'), 'fA/~o\OA/~o\O', 'nomagic substitute() with (wrong) empty optional argument evaluates &')

call vimtest#SaveOut()
call vimtest#Quit()
