au BufRead,BufNewFile *.j2 if &syntax !~ 'jinja' | let &syntax .= '.jinja' | endif
au FileType * if expand('<afile>') =~ '\.j2$' && &syntax !~ 'jinja' | let &syntax .= '.jinja' | endif
