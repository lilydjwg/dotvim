let g:racer_cmd = 'racer'
" https://github.com/phildawes/racer/issues/194
if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
endif
let g:neocomplete#sources#omni#input_patterns.rust =
    \ '[^.[:digit:] *\t]\%(\.\|\::\)\%(\h\w*\)\?'
