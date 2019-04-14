function! neomake#makers#ft#beancount#EnabledMakers() abort
    return ['beancheck']
endfunction

function! neomake#makers#ft#beancount#beancheck() abort
    return {
                \ 'exe': 'bean-check',
                \ 'args': [b:beancount_root],
                \ 'append_file': 0,
                \ }
endfunction

" vim: et sw=4 ts=4
" vim: ts=4 sw=4 et
