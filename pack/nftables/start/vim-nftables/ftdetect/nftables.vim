function! s:DetectFiletype()
    if getline(1) =~# '^#!\s*\%\(/\S\+\)\?/\%\(s\)\?bin/\%\(env\s\+\)\?nft\>'
        setfiletype nftables
    endif
endfunction

augroup nftables
    autocmd!
    autocmd BufRead,BufNewFile * call s:DetectFiletype()
    autocmd BufRead,BufNewFile *.nft,nftables.conf setfiletype nftables
augroup END
