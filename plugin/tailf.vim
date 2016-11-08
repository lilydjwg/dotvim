" tailf.vim	tail -f with jobs
" Author:       lilydjwg <lilydjwg@gmail.com>
" License:	Vim License  (see vim's :help license)

function s:TailfCmd(cmd)
  enew
  let buf = bufnr('%')
  setl buftype=nofile
  if type(a:cmd) == v:t_list
    let displaycmd = join(a:cmd)
  elseif type(a:cmd) == v:t_string
    let displaycmd = a:cmd
  endif
  let name = fnameescape("[CMD] " . displaycmd)
  silent exe "file" name
  let b:job = job_start(a:cmd, {'out_io': 'buffer', 'out_buf': buf})
  " FIXME: why b:job disappears when unloading?
  au BufUnload <buffer> call job_stop(b:job)
endfunction

function s:Tailf(file)
  call s:TailfCmd(['tail', '-f', a:file])
  silent exe "file" fnameescape('[TAILF] ' . fnamemodify(a:file, ':~'))
endfunction

command -nargs=+ -complete=shellcmd TailfCmd call s:TailfCmd(<q-args>)
command -nargs=1 -complete=file Tailf call s:Tailf(<f-args>)
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
