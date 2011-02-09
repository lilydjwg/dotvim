" Vim script file
" FileType:     TeX (common file)
" Author:       lilydjwg
" Maintainer:   lilydjwg
" Last Change:  2011年2月9日

function texcommon#tex2pdf(cmd)
  redir @">
  w
  lcd %:p:h
  exe '!' . a:cmd . ' %'
  redir END
endfunction

function texcommon#view()
  silent !setsid evince %:r.pdf&
endfunction
