" Vim script file
" FileType:     C/C++
" Author:       lilydjwg

" ---------------------------------------------------------------------
" Load Once:
if exists("b:loaded_candcpp")
  finish
endif

let b:loaded_candcpp = 1
" ---------------------------------------------------------------------
" Functions:
function! Lilydjwg_c_malloc()
  " 自动补全 malloc()
  let l = getline('.')
  " FIXME 这个正则匹配是根据我的编程习惯写，并且没有检查后续字符
  let m = matchstr(l, '\v^.*\w+\s*\=\s*\(([[:alnum:] _]+)\*')
  if m != ''
    let n = input('请输入倍数（直接回车为 1）：')
    if n == 1 || n == ''
      let l = substitute(m, '\v\=\s*\(([[:alnum:] _]*\S)\s*\*\zs', ')malloc(sizeof(\1));', '')
    else
      let l = substitute(m, '\v\=\s*\(([[:alnum:] _]*\S)\s*\*\zs', ')malloc('.n.' * sizeof(\1));', '')
    endif
    if &ft == 'c'
      " C 语言中不需要类型转换
      let l = substitute(l, '\v\([^)]+\*\)\zemalloc', '', '')
    endif
    " 清空这一行
    call setline('.', '')
    let l .= "\n"
    return l
  else
    return ""
  endif
endfunction

function! Lilydjwg_c_noCStyle()
  let pos = getpos('.')
  " 将 C 风格的代码改成我喜欢的样式
  let f = tempname()
  sil exe "w ".f
  call system("indent -bap -br -brf -brs -ce -cdw -nlp -ci4 -nss -npcs -ncss -nsaf -npsl -nsai -nsaw -nprs -ppi 3 -sc ".f)
  %d
  sil exe 'r '.f
  setlocal nofoldenable
  1d
  sil %s/)\s\+{/){/ge
  sil %s/\v\}\s+else(\s|\{|)@=/}else/ge
  sil %s/\v(\s|}|)@<=else\s+\{/else{/ge
  sil %s/\v#include\s+("|\<)@=/#include/ge
  sil %s/{\s\+/{/ge
  sil %s/\S\@<=\s\+}/}/ge
  call setpos('.', pos)
endfunction
" ---------------------------------------------------------------------
" 设置/映射/自定义命令
imap <buffer> <silent> <M-m> <C-R>=Lilydjwg_c_malloc()<CR>

" 保存所有并编译当前工程
nmap <buffer> <C-F5> :wa<CR>:make<CR>
" 保存并编译当前文件
nmap <buffer> <C-CR> :CPP<CR>
" 编译好后，运行编译的文件
nmap <buffer> <S-F5> :!%:p:r<CR>

command -buffer CS call Lilydjwg_c_noCStyle()
" 改注释为 /* ... */ （为了某些 C 语言）
command! -buffer TCC %s/\/\/\s*\(.*\)/\/\* \1 \*\//g
command! -buffer TCPP %s=\v/\*\s*(.*)\s*\*/=// \1=g
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
