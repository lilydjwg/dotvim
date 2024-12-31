" License:	Vim License  (see vim's :help license)
" ---------------------------------------------------------------------
" Load Once:
if &cp || exists("g:loaded_colorlog")
  finish
endif
let s:keepcpo = &cpo
let g:loaded_colorlog = 1
set cpo&vim
" ---------------------------------------------------------------------
" Check:
"   check for our executable zhist
if !executable('colorlog')
  finish
endif
" ---------------------------------------------------------------------
" Function:
function s:colorlog_read(file)
  let props = tempname()
  exe 'sil r!colorlog --vim-props' props '< ''' . a:file . ''''
  1d
  " for mru.vim
  doautocmd BufReadPost
  call s:highlight(props)
endfunction
function s:colorlog_read_buffer()
  let props = tempname()
  exe '%!colorlog --vim-props' props
  " for mru.vim
  doautocmd BufReadPost
  call s:highlight(props)
endfunction

let s:prop_types_added = 0
function s:highlight(props)
  if s:prop_types_added == 0
    hi Colorlog_Error ctermfg=darkred
    hi Colorlog_HTTP_Good ctermfg=darkgreen
    hi Colorlog_HTTP_ClientError ctermfg=darkyellow
    hi Colorlog_HTTP_ServerError ctermfg=white ctermbg=darkred
    hi Colorlog_Time_Good ctermfg=white
    hi Colorlog_Time_Moderate ctermfg=darkyellow
    hi Colorlog_Time_Slow ctermfg=lightred
    hi Colorlog_IP ctermfg=darkgreen
    hi Colorlog_IP_Local ctermfg=darkcyan
    hi Colorlog_GeoLocation ctermfg=darkyellow
    hi Colorlog_UserAgent ctermfg=darkmagenta
    hi Colorlog_UserAgent_Highlight ctermfg=lightgreen
    hi Colorlog_Timestamp ctermfg=darkred
    hi Colorlog_Request ctermfg=lightblue
    hi Colorlog_Size ctermfg=gray
    hi Colorlog_Referrer ctermfg=darkcyan

    call prop_type_add('Colorlog_HTTP_Good', {'highlight': 'Colorlog_HTTP_Good'})
    call prop_type_add('Colorlog_HTTP_ClientError', {'highlight': 'Colorlog_HTTP_ClientError'})
    call prop_type_add('Colorlog_HTTP_ServerError', {'highlight': 'Colorlog_HTTP_ServerError'})
    call prop_type_add('Colorlog_Time_Good', {'highlight': 'Colorlog_Time_Good'})
    call prop_type_add('Colorlog_Time_Moderate', {'highlight': 'Colorlog_Time_Moderate'})
    call prop_type_add('Colorlog_Time_Slow', {'highlight': 'Colorlog_Time_Slow'})
    call prop_type_add('Colorlog_IP', {'highlight': 'Colorlog_IP'})
    call prop_type_add('Colorlog_IP_Local', {'highlight': 'Colorlog_IP_Local'})
    call prop_type_add('Colorlog_GeoLocation', {'highlight': 'Colorlog_GeoLocation'})
    call prop_type_add('Colorlog_UserAgent', {'highlight': 'Colorlog_UserAgent'})
    call prop_type_add('Colorlog_UserAgent_Highlight', {'highlight': 'Colorlog_UserAgent_Highlight'})
    call prop_type_add('Colorlog_Timestamp', {'highlight': 'Colorlog_Timestamp'})
    call prop_type_add('Colorlog_Request', {'highlight': 'Colorlog_Request'})
    call prop_type_add('Colorlog_Size', {'highlight': 'Colorlog_Size'})
    call prop_type_add('Colorlog_Referrer', {'highlight': 'Colorlog_Referrer'})
    call prop_type_add('Colorlog_Error', {'highlight': 'Colorlog_Error'})
    let s:prop_types_added = 1
  endif

  setl ft=
  call prop_clear(1, line('$'))
  let lines = readfile(a:props)
  for line in lines
    let prop = json_decode(line)
    call prop_add(prop.lnum, prop.col,
          \ {"type": 'Colorlog_' .. prop.type, "length": prop.length})
  endfor

  call delete(a:props)
endfunction
" ---------------------------------------------------------------------
" Autocmds And Command:
augroup colorlog
 au!
 au BufReadCmd access*.log call s:colorlog_read(expand("<afile>"))
augroup END
command! Colorlog call s:colorlog_read_buffer()
" ---------------------------------------------------------------------
" Restoration And Modelines:
let &cpo = s:keepcpo
unlet s:keepcpo
" ---------------------------------------------------------------------
