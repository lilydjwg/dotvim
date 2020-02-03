" Test maparg() compatibility.

call vimtest#SkipAndQuitIf(v:version < 704, 'Need support for extended maparg().rhs')

" Cannot use the one from helpers/CompatChecker.vim because we need to pass
" additional arguments to the original maparg() one here, and use the rhs
" attribute from the result.
function! IsCompatible( originalFunctionName, description, ... )
    let l:expected = call(a:originalFunctionName, [a:1, '', 0, 1]).rhs
    let l:got = call('ingo#compat#maparg', a:000)
    call vimtap#Is(l:got, l:expected, a:description)
endfunction
let g:IngoLibrary_CompatFor = 'maparg'

call vimtest#StartTap()
call vimtap#Plan(6)

nnoremap <Plug>TestEasy simple
call IsCompatible('maparg', 'simple mapping', '<Plug>TestEasy')

nnoremap <Plug>TestKeyNotation :<C-U>echo<CR>
call IsCompatible('maparg', 'key notation', '<Plug>TestKeyNotation')

nnoremap <Plug>TestBar :echo "<Bar><Bar>foo"<Bar>version <Bar> quit<CR>
call IsCompatible('maparg', 'bar', '<Plug>TestBar')

nnoremap <Plug>TestLt echo "\<lt>Plug><lt>NONO"
call IsCompatible('maparg', '<lt>', '<Plug>TestLt')

nnoremap <SID>(JustATest) gaga
nnoremap <Plug>TestSID :<CR><SID>(JustATest):<CR>
call vimtap#Is(maparg('<Plug>TestSID', '', 0, 1).rhs, ':<CR><SID>(JustATest):<CR>', 'original does not resolve <SID>')
call vimtap#Like(ingo#compat#maparg('<Plug>TestSID'), '^:<CR><SNR>\d\+_(JustATest):<CR>$', 'compatibility wrapper resolves <SID> to <SNR>')

call vimtest#Quit()
