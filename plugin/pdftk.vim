" Vim plugin for editing PDF files.
" Cribbed from gzip.vim, by Bram Moolenaar
" Maintainer: Sid Steward <ssteward@AccessPDF.com>
" Latest Version: www.AccessPDF.com/pdftk/
" Last Change: 2004 Aug 14

" Exit quickly when:
" - this plugin was already loaded
" - when 'compatible' is set
" - some autocommands are already taking care of compressed files
if exists("loaded_pdftk") || &cp || exists("#BufReadPre#*.pdf")
  finish
endif
let loaded_pdftk = 1

augroup pdftk
  " Remove all pdftk autocommands
  au!

  " Enable clear text (uncompressed) editing of pdf files
  " set binary mode before reading the file
  autocmd BufReadPre,FileReadPre	*.pdf  setlocal bin
  autocmd BufReadPost,FileReadPost	*.pdf  call s:read("pdftk")
  autocmd BufWritePost,FileWritePost	*.pdf  call s:write("pdftk")

augroup END

" Function to check that executing "cmd [-f]" works.
" The result is cached in s:have_"cmd" for speed.
fun s:check(cmd)
  let name = substitute(a:cmd, '\(\S*\).*', '\1', '')
  if !exists("s:have_" . name)
    let e = executable(name)
    if e < 0
      let r = system(name);
      let e = (r !~ "not found" && r != "")
    endif
    exe "let s:have_" . name . "=" . e
  endif
  exe "return s:have_" . name
endfun

" After reading compressed file: Uncompress text in buffer with "cmd"
fun s:read(cmd)
  " don't do anything if the cmd is not supported
  if !s:check(a:cmd)
    return
  endif
  " make 'patchmode' empty, we don't want a copy of the written file
  let pm_save = &pm
  set pm=
  " remove 'a' and 'A' from 'cpo' to avoid the alternate file changes
  let cpo_save = &cpo
  set cpo-=a cpo-=A
  " set 'modifiable'
  let ma_save = &ma
  setlocal ma
  " when filtering the whole buffer, it will become empty
  let empty = line("'[") == 1 && line("']") == line("$")
  let tmp = tempname()
  let tmpe = tmp . "." . expand("<afile>:e")
  " write the just read lines to a temp file "'[,']w tmp.pdf"
  execute "silent '[,']w " . tmpe
  " uncompress the temp file, modified for pdftk
  call system(a:cmd . " \"" . tmpe . "\" output \"" . tmp . "\" uncompress")
  " delete the compressed lines; remember the line number
  let l = line("'[") - 1
  if exists(":lockmarks")
    lockmarks '[,']d _
  else
    '[,']d _
  endif
  " read in the uncompressed lines "'[-1r tmp"
  setlocal bin
  if exists(":lockmarks")
    execute "silent lockmarks " . l . "r " . tmp
  else
    execute "silent " . l . "r " . tmp
  endif

  " if buffer became empty, delete trailing blank line
  if empty
    silent $delete _
    1
  endif
  " delete the temp file and the used buffers
  call delete(tmp)
  call delete(tmpe)
  silent! exe "bwipe " . tmp
  silent! exe "bwipe " . tmpe
  let &pm = pm_save
  let &cpo = cpo_save
  let &l:ma = ma_save
  " When uncompressed the whole buffer, do autocommands
  if empty
    if &verbose >= 8
      execute "doau BufReadPost " . expand("%:r")
    else
      execute "silent! doau BufReadPost " . expand("%:r")
    endif
  endif
endfun

" After writing compressed file: Compress written file with "cmd"
fun s:write(cmd)
  " don't do anything if the cmd is not supported
  if s:check(a:cmd)
    let nm = expand("<afile>")
    let tmp = tempname()
    let cmdout = system(a:cmd . " \"" . nm . "\" output \"" . tmp . "\" compress")
    if cmdout !~? "Error:" 
      call rename(tmp, nm)
    else
      echo "An error occured while trying to compress the PDF using pdftk."
    endif
    " refresh buffer from the disk; this prevents the user from
    " receiving errant "file has changed on disk" messages; plus, it does
    " update the buffer to reflect changes made by pdftk at save-time
    execute "edit"
    call s:read("pdftk")
  endif
endfun

" vim: set sw=2 :
