function s:AddSyntax()
  if &syntax !~ '\<jinja\>'
    let &syntax .= '.jinja'
  elseif &syntax == ''
    set syntax=jinja
  endif
endfunction

au BufRead,BufNewFile *.j2 call s:AddSyntax()
au FileType * if expand('<afile>') =~ '\.j2$' | call s:AddSyntax() | endif
