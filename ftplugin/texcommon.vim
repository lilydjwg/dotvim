" Vim script file
" FileType:     XeTeX (common file)
" Author:       lilydjwg
" Maintainer:   lilydjwg
" Last Change:  2009年12月30日
"
function! Lilydjwg_tex_pdf(cmd)
    redir @">
    w
    lcd %:p:h
    " 目录中不要脚注
    " !fixlatex.py %:r.toc
    " !pdflatex %
    exe '!' . a:cmd . ' %'
    silent !setsid evince %:r.pdf&
    redir END
endfunction
