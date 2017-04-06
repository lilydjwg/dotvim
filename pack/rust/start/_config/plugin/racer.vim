let g:racer_cmd = 'racer'
let g:racer_experimental_completer = 1

" https://github.com/phildawes/racer/issues/194
if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.rust =
    \ '[^.[:digit:] *\t]\%(\.\|\::\)\%(\h\w*\)\?'
