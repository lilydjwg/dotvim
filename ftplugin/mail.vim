" Vim script file
" FileType:     mail
" Author:       lilydjwg <lilydjwg@gmail.com>

setlocal formatoptions=tcroqn2m1B

imap <buffer> <BS> <C-R>=Lilydjwg_checklist_bs('\v^\>+ +$')<CR>

if !has("python3")
  finish
endif

function! s:getEncodedHeader(encoding)
  let msg = input('编码头信息: ')
  if msg == ''
    return
  endif
  py3 <<EOP
import email.header, vim
msg = email.header.Header(vim.eval('msg'), vim.eval('a:encoding')).encode()
vim.command('let msg = "%s"' % msg)
EOP
  return msg
endfunction

imap <buffer> <M-g> <C-R>=<SID>getEncodedHeader("gb2312")<CR>
imap <buffer> <M-u> <C-R>=<SID>getEncodedHeader("utf-8")<CR>
imap <buffer> <M-a> Attach: <C-R>=input('Attach file: ', '', 'file')<CR>
