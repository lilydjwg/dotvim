" scratch.vim
" Author: Abhilash Koneri (abhilash_koneri at hotmail dot com)
" Improved By: Hari Krishna Dara (hari_vim at yahoo dot com)
" Last Change: 25-Feb-2004 @ 09:48
" Created: 17-Aug-2002
" Version: 1.0.0
" Download From:
"     http://www.vim.org/script.php?script_id=389
"----------------------------------------------------------------------
" This is a simple plugin that creates a scratch buffer for your
" vim session and helps to access it when you need it.  
"
" If you like the custom mappings provided in the script - hitting
" <F8> should create a new scratch buffer. You can do your scribes
" here and if you want to get rid of it, hit <F8> again inside scratch buffer
" window. If you want to get back to the scratch buffer repeat <F8>. Use
" <Plug>ShowScratchBuffer and <Plug>InsShowScratchBuffer to customize these
" mappings.
"
" If you want to designate a file into which the scratch buffer contents
" should automatically be dumped to, when Vim exits, set its path to
" g:scratchBackupFile global variable. This file can be accessed just in case
" you happen to have some important information in the scratch buffer and quit
" Vim (or shutdown the m/c) forgetting to copy it over. The target file is
" force overwritten using the :write! command so make sure you set a file name
" that can accidentally be used for other purposes (especially when you use
" relative paths). I recommend a value of '/tmp/scratch.txt'.
" CAUTION: This feature works only when Vim generates VimLeavePre autocommad.
"
" Custom mappings
" ---------------
" The ones defined below are not very ergonomic!
"----------------------------------------------------------------------
"Standard Inteface:  <F8> to make a new ScratchBuffer, <F8>-again to hide one

if exists('loaded_scratch')
  finish
endif
let loaded_scratch = 1

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

" lilydjwg: 有点问题；还是我自己来映射吧
" if (! exists("no_plugin_maps") || ! no_plugin_maps) &&
"       \ (! exists("no_scratch_maps") || ! no_scratch_maps)
"   if !hasmapto('<Plug>ShowScratchBuffer',"n")
"     nmap <unique> <silent> <F8> <Plug>ShowScratchBuffer
"   endif
"   if !hasmapto('<Plug>InsShowScratchBuffer',"i")
"     imap <unique> <silent> <F8> <Plug>InsShowScratchBuffer
"   endif
" endif

" User Overrideable Plugin Interface
nmap <script> <silent> <Plug>ShowScratchBuffer
      \ :silent call <SID>ShowScratchBuffer()<cr>
imap <script> <silent> <Plug>InsShowScratchBuffer
      \ <c-o>:silent call <SID>ShowScratchBuffer()<cr>

command! -nargs=0 Scratch :call <SID>ShowScratchBuffer()

if !exists('g:scratchBackupFile')
  let g:scratchBackupFile = '' " So that users can easily find this var.
endif
aug ScratchBackup
  au!
  au VimLeavePre * :call <SID>BackupScratchBuffer()
aug END

let s:SCRATCH_BUFFER_NAME="[Scratch]"
if !exists('s:buffer_number') " Supports reloading.
  let s:buffer_number = -1
endif

"----------------------------------------------------------------------
" Diplays the scratch buffer. Creates one if it is an already 
" present
"----------------------------------------------------------------------
function! <SID>ShowScratchBuffer()
  if(s:buffer_number == -1 || bufexists(s:buffer_number) == 0)
    " Temporarily modify isfname to avoid treating the name as a pattern.
    let _isf = &isfname
    set isfname-=\
    set isfname-=[
    if exists('+shellslash')
      exec "sp \\\\". s:SCRATCH_BUFFER_NAME
    else
      exec "sp \\". s:SCRATCH_BUFFER_NAME
    endif
    let &isfname = _isf
    let s:buffer_number = bufnr('%')
  else
    let buffer_win=bufwinnr(s:buffer_number)
    if(buffer_win == -1)
      exec 'sb '. s:buffer_number
    else
      exec buffer_win.'wincmd w'
    endif
  endif
  " Do setup always, just in case.
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal nobuflisted
  setlocal noswapfile
  setlocal noro
  nmap <buffer> <silent> <Plug>ShowScratchBuffer :hide<cr>
  imap <buffer> <silent> <Plug>InsShowScratchBuffer <c-o>:hide<cr>
  command! -buffer -nargs=0 Scratch :hide
  " lilydjwg
  " FIXME 终端下无效
  inoremap <buffer> <silent> <S-CR> <ESC>:call <SID>scratch_eval('vim')<CR>
  inoremap <buffer> <silent> <C-CR> <ESC>:call <SID>scratch_eval('python')<CR>
endfunction

function s:scratch_eval(engine)
  let exp = getline('.')
  if a:engine == 'vim'
    try
      let r = eval(exp)
    catch /E15:/
      let r = 'E15: 无效的表达式'
    catch /E121:/
      let r = 'E121: 未定义的变量'
    catch /E488:/
      let r = 'E488: 多余的尾部字符'
    endtry
  elseif a:engine == 'python'
    " 换行符的处理
    " FIXME 单引号转义
    let rstr = system('python3 -c ''print('.exp.')''')
    let r = split(rstr, '\n')
  endif
  call append('.', r)
  startinsert!
endfunction
function! s:BackupScratchBuffer()
  if s:buffer_number != -1 && exists('g:scratchBackupFile') &&
        \ g:scratchBackupFile != ''
    exec 'split #' . s:buffer_number
    " Avoid writing empty scratch buffers.
    if line('$') > 1 || getline(1) !~ '^\s*$'
      let _cpo=&cpo
      try
        set cpo-=A
        exec 'write!' g:scratchBackupFile
      finally
        let &cpo=_cpo
      endtry
    endif
  endif
endfunction

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6: sw=2 et
