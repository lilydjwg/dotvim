" Vim script file
" FileType:     RJ （日记）
" Author:       lilydjwg
" Last Change:  2010-10-14

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

" maps
" 插入模式下回车后自动空四格，第二次时取消上一行的空格
inoremap <buffer> <CR> <C-R>=Lilydjwg_rj_cr()<CR>
" 删除行首的空格
"   FIXME 这样会造成 Vimim 不正常
inoremap <buffer> <silent> <BS> <C-R>=Lilydjwg_rj_bs()<CR>
" 用 Shift-Enter 代替原来的 Enter
inoremap <buffer> <S-CR> <CR>
" 首个 Tab 输入四个空格
inoremap <buffer> <Tab> <C-R>=Lilydjwg_rj_tab()<CR>
nnoremap <buffer> ~ i~ <C-R>=strftime("%Y-%m-%d %H:%M")<CR>~<ESC>F~a
nnoremap <buffer> j gj
nnoremap <buffer> k gk
nnoremap <buffer> <Up> gk
nnoremap <buffer> <Down> gj
vnoremap <buffer> j gj
vnoremap <buffer> k gk
vnoremap <buffer> <Up> gk
vnoremap <buffer> <Down> gj
nnoremap <buffer> <silent> <C-]> :call Lilydjwg_rj_tag()<CR>
nnoremap <buffer> <silent> <CR> :call Lilydjwg_rj_tag()<CR>

setl nocursorline
colorscheme lilypink
setlocal ft=rj
setlocal nonumber
setlocal fdm=expr
setlocal foldexpr=getline(v:lnum)=~'^\\v\\d{4}年'?'>1':1

function! Lilydjwg_rj_bs()
  let l = getline('.')
  if l =~ '^\s\+$'
    call setline('.', '')
  else
    return "\<BS>"
  endif
  return ''
endfunction

function! Lilydjwg_rj_cr()
  let l = getline('.')
  if l =~ '^\s\+$'
    call setline('.', '')
  endif
  return "\<CR>    "
endfunction

function! Lilydjwg_rj_tab()
  let l = getline('.')
  if l =~ '^$'
    return '    '
  else
    " return "\<Tab>"
    return CleverTab()
  endif
endfunction

if !exists('*Lilydjwg_rj_tag')
  function Lilydjwg_rj_tag()
    let date = Lilydjwg_get_pattern_at_cursor('\v(\d{4}年)?(\d{1,2}|元)月\d{1,2}日')
    let date = substitute(date, '元', '1', '')
    if date == ''
      echohl WarningMsg
      echo '光标处没有找到日期！'
      echohl None
      return
    endif
    if match(date, '\v\d{4}年') == -1 "没有年的信息
      let date = matchstr(expand('%:t'), '\v^\d{4}\ze\.rj') . '年' . date
    endif
    let b:year = matchstr(date, '\v^\d{4}')
    if b:year != matchstr(expand('%:t'), '\v^\d{4}\ze\.rj') "不在同一个文件内
      if &modified
	w
      endif
      let file = expand('%:p:h') . '/' . b:year . '.rj'
      exe 'e ' . file
    endif
    let date = '^' . date
    if search(date, 'ws') == 0
      echohl WarningMsg
      echo '没有找到 '.strpart(date, 1).' 的日记！'
      echohl None
    endif
  endfunction
endif

" vim:fdm=expr:fde=getline(v\:lnum)=~'^\\s*$'&&getline(v\:lnum+1)=~'\\S'?'<1'\:1
