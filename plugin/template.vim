" template.vim  自动载入 template 文件
" Author:       lilydjwg
" Maintainer:   lilydjwg
" Last Change:  2009年8月31日
" License:	Vim License  (see vim's :help license)
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_template")
 finish
endif
let s:keepcpo = &cpo
let g:loaded_template = 1
set cpo&vim
" ---------------------------------------------------------------------
" Functions:
function LoadTemplate(read)
  " read 指示是新文件还是在读取文件

  " 另作处理的文件类型
  if expand("%:t") =~ '\.h$'
    return
  endif

  if (has("win32") || has("win95") || has("win64") || has("win16"))
    let templatePrefix = '$VIM/vimfiles/templates/template.'
  else
    let templatePrefix = '~/.vim/templates/template.'
  endif
  let fname = templatePrefix . &ft
  let fname = expand(fname)
  if a:read == 0 && filereadable(fname)
    sil exe 'read ' . fname
    " 删除空行
    normal ggdd
    setlocal nomodified
  endif
  exe "command! -buffer Template :tabe " . fname
endfunction
function Lilydjwg_c_SetHeader()
  " *.h 文件做点别的
  let d=["//=====================================================================",
	\"// ",
	\"//=====================================================================",
	\"#ifndef CHEADER",
	\"#define CHEADER",
	\"//---------------------------------------------------------------------",
	\"//---------------------------------------------------------------------",
	\"#endif",
	\"//====================================================================="]
  let hr = toupper(expand('%:t:r')).'_HEADER'
  call map(d, 'substitute(v:val, "CHEADER", "'.hr.'", "g")')
  call append(1, d)
  1d
  normal 2G$
endfunction
" ---------------------------------------------------------------------
" Autocmds:
au BufNewFile	* call LoadTemplate(0)
au BufRead	* call LoadTemplate(1)
au BufNewFile *.h call Lilydjwg_c_SetHeader()
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
