" rcode.vim	Run variable type of code again current buffer
" Version:	1.0
" Author:       lilydjwg <lilydjwg@gmail.com>
" URL:		http://www.vim.org/scripts/script.php?script_id=3705
" ---------------------------------------------------------------------
" Usage:
" Command 'Rcode' with argument vim, awk, perl, py, py3, ruby or lua will
" open a new buffer. Write your code in it and use command 'Run' (or key map
" <C-CR>) to run it again the buffer you were.
"
" Shortcut:
" in Python, 'v' is the 'vim' module, and 'b' is the current buffer,
" in Lua, 'b' is the current buffer,
"
" Settings:
" The global 'g:Rcode_after' indicates what to do after running your code.
" 0 means to do noting, 1 means to close the code buffer and 2 will throw away
" your code besides closing the buffer. Default is 1.
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_rcode")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_vimrcode = 1
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
if !exists('g:Rcode_code')
  let g:Rcode_code = {}
endif
" ---------------------------------------------------------------------
" Functions:
function s:Rcode_complete(ArgLead, CmdLine, CursorPos)
  return keys(s:lang2ft)
endfunction
function s:Rcode_init(nr, lang) range
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
  rightbelow 7split [Rcode]
  set buftype=nofile
  let &filetype = s:lang2ft[a:lang]
  %d "清除模板之类的东西
  setlocal nofoldenable
  let b:firstline = a:firstline
  let b:lastline = a:lastline
  let b:nr = a:nr
  let b:lang = a:lang
  nnoremap <buffer> <silent> q <C-W>c
  nnoremap <buffer> <silent> <C-CR> :call <SID>Rcode_run()<CR>
  inoremap <buffer> <silent> <C-CR> <Esc>:call <SID>Rcode_run()<CR>
  inoremap <buffer> <silent> <C-C> <Esc><C-W>c
  command! -buffer Run call s:Rcode_run()
  if has_key(g:Rcode_code, a:lang)
    call setline(1, g:Rcode_code[a:lang])
  else
    startinsert
  endif
endfunction
function s:Rcode_run()
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

  if !exists("g:Rcode_after") || g:Rcode_after == 1 "close
    let g:Rcode_code[lang] = getline(1, '$')
    q
  elseif g:Rcode_after == 2 "empty
    %d
  elseif g:Rcode_after == 0 "do nothing
  endif
endfunction
" ---------------------------------------------------------------------
" Commands:
command -nargs=1 -complete=customlist,s:Rcode_complete -range=%
      \ Rcode <line1>,<line2>call s:Rcode_init(winnr(), <q-args>)
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
