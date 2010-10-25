" Vim script file
" FileType:     wiki (Wikipedia)
" Author:       lilydjwg
" Last Change:  2010-10-23

" 原有映射 {{{1
setlocal encoding=utf-8
setlocal textwidth=0
nnoremap <buffer> k gk
nnoremap <buffer> j gj
nnoremap <buffer> <Up> gk
nnoremap <buffer> <Down> gj
inoremap <buffer> <Up> <C-O>gk
inoremap <buffer> <Down> <C-O>gj
xnoremap <buffer> k gk
xnoremap <buffer> j gj
xnoremap <buffer> <Up> gk
xnoremap <buffer> <Down> gj

" 我自定义的映射 {{{1
nmap <silent> <buffer> = :call Lilydjwg_wiki_title(1)<CR>
nmap <silent> <buffer> + :call Lilydjwg_wiki_title(0)<CR>
nmap <buffer> <Space> I <ESC>
vmap <buffer> [ <ESC>`>a]<ESC>`<i[<ESC>
vmap <buffer> ] <ESC>`<i[<ESC>`>la]<ESC>
vmap <buffer> <Space> ^<C-V>I <ESC>
imap <buffer> * <C-R>=Lilydjwg_wiki_checklist()<CR>
" 这里不能用 Lilydjwg_checklist_bs() 取代
imap <buffer> <silent> <BS> <C-R>=Lilydjwg_wiki_checklist_bs()<CR>

" m 开头的映射 {{{1
nnoremap <buffer> <silent> mt :call Lilydjwg_wiki_tablerow()<CR>
vmap <buffer> m[ <ESC>`>a]]<ESC>`<i[[<ESC>
vmap <buffer> m] <ESC>`>a]]<ESC>`<i[[<ESC>f];
vmap <buffer> mc <ESC>`>a}}<ESC>`<i{{代码<Bar><ESC>f};

function! Lilydjwg_wiki_title(op) "{{{1
  let l = substitute(getline('.'), '^\s\+\|\s\+$', '', 'g')
  if a:op
    if l =~ '=.\+='
      call setline('.', '='.l.'=')
    else
      call setline('.', '= '.l.' =')
    endif
  else
    if l =~ '^= .\+ =$'
      call setline('.', strpart(l, 2, strlen(l)-4))
    elseif l =~ '=.\+='
      call setline('.', strpart(l, 1, strlen(l)-2))
    else
    endif
  endif
endfunction
function! Lilydjwg_wiki_checklist() "{{{1
  if getline('.') =~ '\v^\*+ $'
    s/\v^(\*+) /\1\* /
    return "\<C-O>A"
  else
    return '*'
  endif
endfunction

function! Lilydjwg_wiki_checklist_bs() "{{{1
  if getline('.') =~ '\v^\*{2,} $'
    s/\v^\*(\*+) /\1\ /
    return "\<C-O>A"
  elseif getline('.') =~ '\v^\*+ $'
    call setline(line('.'), '')
    return ""
  else
    return "\<BS>"
  endif
endfunction

function! Lilydjwg_wiki_tablerow() "{{{1
  exe "normal! O|-"
  exe "normal! j"
  while getline('.') !~ '^\s*$' && line('.') != line('$')
    exe "normal! 0i| "
    exe "normal! j"
  endwhile
endfunction

" 设置 {{{1
setlocal isk+=_
setlocal fo-=c
setlocal comments+=n:*
runtime ftplugin/xml/xml.vim
runtime ftplugin/xml/htAndxml.vim
" 这个是 xml.vim 增加的
setlocal isk-=:

" vim modeline " {{{1
" vim:fdm=marker:fmr={{{,}}}
