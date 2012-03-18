" rcode.vim	Run variable type of code against current buffer
" Version:	2.0
" Author:       lilydjwg <lilydjwg@gmail.com>
" URL:		http://www.vim.org/scripts/script.php?script_id=3705
" ---------------------------------------------------------------------
" Commands And Maps:
" :Rcode		Start Rcode. Accept an argument as the language, eg:
" 			vim, awk, etc. Use <C-D> to see all available ones.
" 			A new buffer will be opened for you. Write your code
" 			in it.
" 			You can give a range.
"
" :RcLoad {name}	Load a previous saved code snippet.
"			"name" should be in the form "{lang}/{filename}" so
"			that the script knows which language it's in. This is
"			different from ":Save" command.
" 			You can give a range.
"
" :RcSelect		List all available code snippets and you can choose
"			one by number
"
" In Rcode buffer:
"
" <C-CR>
" :Run			Run your code against the buffer you were.
" :Save {name}		Save your code so you can later load it with
"			":RcLoad"
"
" Shortcut:
" in Python, 'v' is the 'vim' module, and 'b' is the current buffer,
" in Lua, 'b' is the current buffer.
"
" Settings:
" g:Rcode_after		what to do after running your code.
" 			0 means to do noting, 1 means to close the code buffer
" 			and 2 will throw away your code besides closing the
" 			buffer, or you code will be loaded next time you use
" 			":Rcode".
" 			Default is 1.
"
" g:Rcode_snippet_path	Where you saved code snippets will lie.
" 			Default is "$HOME/.vim/rcode"
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
if !exists('g:Rcode_snippet_path')
  let g:Rcode_snippet_path = expand("$HOME/.vim/rcode")
endif
" ---------------------------------------------------------------------
" Functions:
function s:Rcode_complete(ArgLead, CmdLine, CursorPos)
  return join(keys(s:lang2ft), "\n")
endfunction
function s:Rcode_complsnippet(ArgLead, CmdLine, CursorPos)
  let prefix_len = len(g:Rcode_snippet_path) + 1
  if exists('+shellslash')
    let ssl = &shellslash
    set shellslash
  endif
  let ret = filter(map(split(globpath(g:Rcode_snippet_path, "*/*"), "\n"),
	\ "strpart(v:val, " . prefix_len . ")"),
	\ "stridx(v:val, '" . a:ArgLead . "') != -1")
  call filter(ret, "has_key(s:lang2ft, split(v:val, '/')[0])")
  if exists('+shellslash')
    let &shellslash = ssl
  endif
  return ret
endfunction
function s:Rcode_init(nr, lang, issnippet) range
  if a:issnippet
    let args = split(a:lang, '/')
    if len(args) != 2
      echohl ErrorMsg
      echo "Bad argument"
      echohl None
      return
    endif
    let lang = args[0]
    let file = g:Rcode_snippet_path . '/' . a:lang
    unlet args
    if !filereadable(file)
      echohl ErrorMsg
      echo "File not readable"
      echohl None
      return
    endif
  else
    let lang = a:lang
    let file = ''
  endif

  if !has_key(s:lang2ft, lang)
    echohl ErrorMsg
    echo "Unavailable script language " . lang
    echohl None
    return
  endif
  if lang == 'py3'
    py3 import vim; v = vim; b = v.current.buffer
  elseif lang == 'py'
    py import vim; v = vim; b = v.current.buffer
  elseif lang == 'lua'
    lua b = vim.buffer()
  endif
  rightbelow 7split [Rcode]
  set buftype=nofile
  let &filetype = s:lang2ft[lang]
  %d_ "清除模板之类的东西
  setlocal nofoldenable
  let b:firstline = a:firstline
  let b:lastline = a:lastline
  let b:nr = a:nr
  let b:lang = lang
  nnoremap <buffer> <silent> q <C-W>c
  nnoremap <buffer> <silent> <C-CR> :call <SID>Rcode_run()<CR>
  inoremap <buffer> <silent> <C-CR> <Esc>:call <SID>Rcode_run()<CR>
  inoremap <buffer> <silent> <C-C> <Esc><C-W>c
  command! -buffer Run call s:Rcode_run()
  command! -buffer -nargs=1 -bang Save call s:Rcode_save(<q-args>, "<bang>")
  if file != ''
    call setline(1, readfile(file))
  elseif has_key(g:Rcode_code, lang)
    call setline(1, g:Rcode_code[lang])
  else
    startinsert
  endif
endfunction
function s:Rcode_save(name, bang)
  let fp = g:Rcode_snippet_path . '/' . b:lang
  if !isdirectory(fp)
    call mkdir(fp, 'p')
  endif

  let fp .= '/' . a:name
  if filewritable(fp) && a:bang != '!'
    echohl ErrorMsg
    echo "File exists (add ! to override)"
    echohl None
    return 0
  endif
  call writefile(getline(1, '$'), fp)
  echo "Saved!"
  return 1
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
    call writefile(getline(1, '$'), file)
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
    %d_
  elseif g:Rcode_after == 0 "do nothing
  endif
endfunction
function s:Rcode_select() range abort
  let list = s:Rcode_complsnippet('', '', 0)
  if len(list) == 0
    echohl WarningMsg | echo "No available code snippets." | echohl None
    return
  endif

  echohl PreProc | echo "Available code snippets:"
  echohl Title | echo "#\tlang\tname\n" | echohl None
  let i = 1
  for name in list
    let [lang, n] = split(name, '/')
    echon i . ".\t"
    echohl Directory
    echon lang
    echohl None
    echon "\t" . n . "\n"
    let i = i + 1
  endfor
  let res = input('Type number and <Enter> (empty cancels): ') + 0
  if res < 1 || res > len(list)
    return
  endif

  exe a:firstline . ',' . a:lastline . 'call s:Rcode_init(' . winnr()
	\ . ", '" . list[(res - 1)] . "', 1)"
endfunction
" ---------------------------------------------------------------------
" Commands:
command -nargs=1 -complete=custom,s:Rcode_complete -range=%
      \ Rcode <line1>,<line2>call s:Rcode_init(winnr(), <q-args>, 0)
command -nargs=1 -complete=customlist,s:Rcode_complsnippet -range=%
      \ RcLoad <line1>,<line2>call s:Rcode_init(winnr(), <q-args>, 1)
command -nargs=0 -range=%
      \ RcSelect <line1>,<line2>call s:Rcode_select()
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
