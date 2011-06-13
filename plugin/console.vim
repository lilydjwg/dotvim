" vimconsole.vim 打开一个窗口来输入代码，并在原窗口执行
" Author:       lilydjwg <lilydjwg@gmail.com>
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_console")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_vimconsole = 1
set cpo&vim
" ---------------------------------------------------------------------
" Variables:
let s:lang2ft = { 'vim': 'vim' }
if executable('awk') | let s:lang2ft['awk'] = 'awk' | endif
if has('lua') | let s:lang2ft['lua'] = 'lua' | endif
if has('perl') | let s:lang2ft['perl'] = 'perl' | endif
if has('python3') | let s:lang2ft['py3'] = 'python' | endif
if has('python') | let s:lang2ft['py'] = 'python' | endif
if has('ruby') | let s:lang2ft['ruby'] = 'ruby' | endif
if !exists('g:Console_code')
  let g:Console_code = {}
endif
" ---------------------------------------------------------------------
" Functions:
function s:Console_complete(ArgLead, CmdLine, CursorPos)
  return keys(s:lang2ft)
endfunction
function s:Console_init(nr, lang) range
  if !has_key(s:lang2ft, a:lang)
    echohl ErrorMsg
    echo "Unsupported script language " . a:lang
    echohl None
    return
  endif
  if a:lang == 'py3'
    py3 import vim; v = vim; b = v.current.buffer
  elseif a:lang == 'py'
    py import vim; v = vim; b = v.current.buffer
  elseif a:lang == 'lua'
    lua b = vim.buffer()
  endif
  rightbelow 7split [Console]
  set buftype=nofile
  let &filetype = s:lang2ft[a:lang]
  %d "清除模板之类的东西
  setlocal nofoldenable
  let b:firstline = a:firstline
  let b:lastline = a:lastline
  let b:nr = a:nr
  let b:lang = a:lang
  nnoremap <buffer> <silent> q <C-W>c
  nnoremap <buffer> <silent> <C-CR> :call <SID>Console_run()<CR>
  inoremap <buffer> <silent> <C-CR> <Esc>:call <SID>Console_run()<CR>
  inoremap <buffer> <silent> <C-C> <Esc><C-W>c
  command! -buffer Run call s:Console_run()
  if has_key(g:Console_code, a:lang)
    call setline(1, g:Console_code[a:lang])
  else
    startinsert
  endif
endfunction
function s:Console_run()
  let self = winnr()
  let lang = b:lang
  let firstline = b:firstline
  let lastline = b:lastline
  let nr = b:nr
  if lang == 'perl'
    exe nr.'wincmd w'
    sil exe "perl" join(getline(1, '$'))
  else
    let file = tempname()
    exe 'w' file
    exe nr.'wincmd w'
    if lang == 'awk'
      sil exe firstline.','.lastline . "!awk -f" file
    elseif lang == 'lua'
      sil exe firstline.','.lastline . "luafile" file
    elseif lang == 'py'
      sil exe firstline.','.lastline . "pyfile" file
    elseif lang == 'py3'
      sil exe firstline.','.lastline . "py3file" file
    elseif lang == 'ruby'
      sil exe firstline.','.lastline . "rubyfile" file
    elseif lang == 'vim'
      sil exe "source" file
    endif
    call delete(file)
  endif
  exe self.'wincmd w'

  if !exists("g:Console_after") || g:Console_after == 1 "关闭
    let g:Console_code[lang] = getline(1, '$')
    q
  elseif g:Console_after == 2 "清空
    %d
  elseif g:Console_after == 0 "无动作
  endif
endfunction
" ---------------------------------------------------------------------
" Commands:
command -nargs=1 -complete=customlist,s:Console_complete -range=%
      \ Console <line1>,<line2>call s:Console_init(winnr(), <q-args>)
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
