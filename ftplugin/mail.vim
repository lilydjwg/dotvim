" Vim script file
" FileType:     mail
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2010-11-06

setlocal tw=70
setlocal formatoptions=tcroqn2mM1
setlocal foldmethod=syntax

imap <buffer> <BS> <C-R>=Lilydjwg_checklist_bs('\v^\>+ +$')<CR>

function! s:getEncodedHeader(encoding)
  let msg = input('头信息: ')
  py <<EOP
import email.header, vim
msg = email.header.Header(unicode(vim.eval('msg'), 'utf-8'),
  vim.eval('a:encoding')).encode()
vim.command('let msg = "%s"' % msg)
EOP
  return msg
endfunction

if has("gui_running")
  imap <buffer> <M-g> <C-R>=<SID>getEncodedHeader("gb2312")<CR>
  imap <buffer> <M-u> <C-R>=<SID>getEncodedHeader("utf-8")<CR>
else
  imap <buffer> <Esc>g <C-R>=<SID>getEncodedHeader("gb2312")<CR>
  imap <buffer> <Esc>u <C-R>=<SID>getEncodedHeader("utf-8")<CR>
endif
