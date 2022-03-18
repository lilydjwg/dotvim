function! IsCompatible( originalFunctionName, description, ... )
    let l:compatFunctionName = 'ingo#compat#' . a:originalFunctionName

    let l:expected = call(a:originalFunctionName, a:000)
    let l:got = call(l:compatFunctionName, a:000)
    call vimtap#Is(l:got, l:expected, a:description)
endfunction
