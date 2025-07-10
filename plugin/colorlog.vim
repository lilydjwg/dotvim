vim9script
# License:	Vim License  (see vim's :help license)
# ---------------------------------------------------------------------
# Load Once:
if &cp || exists("g:loaded_colorlog")
  finish
endif
var keepcpo = &cpo
g:loaded_colorlog = 1
set cpo&vim
# ---------------------------------------------------------------------
# Check:
#   check for our executable zhist
if !executable('colorlog')
  finish
endif
# ---------------------------------------------------------------------
# Function:
def Colorlog_read(file: string)
  var props = tempname()
  exe 'sil r!colorlog --vim-props' props '< ''' .. file .. ''''
  :1d
  # for mru.vim
  doautocmd BufReadPost
  Highlight(props)
enddef
def Colorlog_read_buffer()
  var props = tempname()
  exe ':%!colorlog --vim-props' props
  # for mru.vim
  Highlight(props)
enddef

def Do_hi_cmds()
  hi Colorlog_Error ctermfg=darkred guifg=#aa0000
  hi Colorlog_HTTP_Good ctermfg=darkgreen guifg=#00aa00
  hi Colorlog_HTTP_ClientError ctermfg=darkyellow guifg=#cfcf00
  hi Colorlog_HTTP_ServerError ctermfg=white ctermbg=darkred guifg=#ffffff guibg=#aa0000
  hi Colorlog_Time_Good ctermfg=white guifg=#ffffff
  hi Colorlog_Time_Moderate ctermfg=darkyellow guifg=#cfcf00
  hi Colorlog_Time_Slow ctermfg=lightred guifg=#ff5555
  hi Colorlog_IP ctermfg=darkgreen guifg=#00aa00
  hi Colorlog_IP_Local ctermfg=darkcyan guifg=#00aaaa
  hi Colorlog_GeoLocation ctermfg=darkyellow guifg=#cfcf00
  hi Colorlog_UserAgent ctermfg=darkmagenta guifg=#a900aa
  hi Colorlog_UserAgent_Highlight ctermfg=green guifg=#55ff55
  hi Colorlog_Timestamp ctermfg=darkred guifg=#aa0000
  hi Colorlog_Request ctermfg=blue guifg=#2660ff
  hi Colorlog_Size ctermfg=gray guifg=#aaaaaa
  hi Colorlog_Referrer ctermfg=darkcyan guifg=#00aaaa
enddef

var prop_types_added = 0
def Highlight(props: string)
  if prop_types_added == 0
    Do_hi_cmds()

    prop_type_add('Colorlog_HTTP_Good', {highlight: 'Colorlog_HTTP_Good'})
    prop_type_add('Colorlog_HTTP_ClientError', {highlight: 'Colorlog_HTTP_ClientError'})
    prop_type_add('Colorlog_HTTP_ServerError', {highlight: 'Colorlog_HTTP_ServerError'})
    prop_type_add('Colorlog_Time_Good', {highlight: 'Colorlog_Time_Good'})
    prop_type_add('Colorlog_Time_Moderate', {highlight: 'Colorlog_Time_Moderate'})
    prop_type_add('Colorlog_Time_Slow', {highlight: 'Colorlog_Time_Slow'})
    prop_type_add('Colorlog_IP', {highlight: 'Colorlog_IP'})
    prop_type_add('Colorlog_IP_Local', {highlight: 'Colorlog_IP_Local'})
    prop_type_add('Colorlog_GeoLocation', {highlight: 'Colorlog_GeoLocation'})
    prop_type_add('Colorlog_UserAgent', {highlight: 'Colorlog_UserAgent'})
    prop_type_add('Colorlog_UserAgent_Highlight', {highlight: 'Colorlog_UserAgent_Highlight'})
    prop_type_add('Colorlog_Timestamp', {highlight: 'Colorlog_Timestamp'})
    prop_type_add('Colorlog_Request', {highlight: 'Colorlog_Request'})
    prop_type_add('Colorlog_Size', {highlight: 'Colorlog_Size'})
    prop_type_add('Colorlog_Referrer', {highlight: 'Colorlog_Referrer'})
    prop_type_add('Colorlog_Error', {highlight: 'Colorlog_Error'})
    prop_types_added = 1
  endif

  setl ft=colorlog
  prop_clear(1, line('$'))
  var lines = readfile(props)
  for line in lines
    var prop = json_decode(line)
    prop_add(prop[1], prop[2],
          \ {"type": 'Colorlog_' .. prop[0], "length": prop[3]})
  endfor

  delete(props)
enddef
# ---------------------------------------------------------------------
# Autocmds And Command:
augroup colorlog
 au!
 au BufReadCmd access*.log Colorlog_read(expand("<afile>"))
 au ColorScheme * Do_hi_cmds()
augroup END
command! Colorlog Colorlog_read_buffer()
# ---------------------------------------------------------------------
# Restoration And Modelines:
&cpo = keepcpo
# ---------------------------------------------------------------------
