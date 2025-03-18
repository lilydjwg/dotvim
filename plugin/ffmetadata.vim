" ffmetadata.vim   use ffmpeg to edit media metadata
" Author:       lilydjwg
" License:	Vim License  (see vim's :help license)
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_ffmetadata")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_ffmetadata = 1
set cpo&vim
" ---------------------------------------------------------------------
" Check:
"   check for our executable zhist
if !executable('ffmpeg')
  finish
endif
" ---------------------------------------------------------------------
" Function:
function s:ffmetadataRead(file)
  let f = a:file->substitute("'", "'\"'\"'", 'g')
  if ['ogg', 'opus']->index(fnamemodify(f, ':e')) >= 0
    exe 'sil r!ffmpeg -loglevel error -i ''' . f . '''' '-map_metadata 0:s -f ffmetadata -'
    if line('$') == 5
      %del _
      exe 'sil r!ffmpeg -loglevel error -i ''' . f . '''' '-f ffmetadata -'
    endif
  else
    exe 'sil r!ffmpeg -loglevel error -i ''' . f . '''' '-f ffmetadata -'
  endif
  1d
  doautocmd BufReadPost
endfunction
function s:ffmetadataWrite(file)
  let f = a:file->substitute("'", "'\"'\"'", 'g')
  let newfile_raw = fnamemodify(a:file, ':r') . '.tmp' . '.' . fnamemodify(f, ':e')
  let newfile = fnamemodify(f, ':r') . '.tmp' . '.' . fnamemodify(f, ':e')
  if ['ogg', 'opus']->index(fnamemodify(f, ':e')) >= 0
    exe 'sil w !ffmpeg -loglevel error -i ''' . f . '''' '-i - -map_metadata:s 1 -codec copy' '''' . newfile . ''''
  else
    exe 'sil w !ffmpeg -loglevel error -i ''' . f . '''' '-i - -map_metadata 1 -codec copy' '''' . newfile . ''''
  endif
  call rename(newfile_raw, a:file)
  set nomodified
  doautocmd BufWritePost
endfunction
" ---------------------------------------------------------------------
" Autocmds:
augroup ffmetadata.vim
 au!
 au BufReadCmd   *.mp3,*.opus,*.ogg,*.m4a,*.wma,*.flac call s:ffmetadataRead(expand("<afile>"))
 au BufWriteCmd  *.mp3,*.opus,*.ogg,*.m4a,*.wma,*.flac call s:ffmetadataWrite(expand("<afile>"))
augroup END
" ---------------------------------------------------------------------
"  Restoration And Modelines:
let &cpo= s:keepcpo
unlet s:keepcpo
" ---------------------------------------------------------------------
