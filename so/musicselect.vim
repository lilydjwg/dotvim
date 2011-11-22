" musicselect.vim       Select Music
" Author:       lilydjwg <lilydjwg@gmail.com>
" Last Change:  2011年2月10日
" ---------------------------------------------------------------------
if !has("python3")
  finish
endif
" ---------------------------------------------------------------------
function! s:setup()
  let b:musicdir = expand('~/音乐')
  let songs = split(system('cd ' . b:musicdir . ' && find -type f ! -name "*~" ! -name "*.lrc"'), '\n')
  call append(0, songs)
  $del _
  1
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal statusline=Music\ Select
  setlocal tabstop=12
  py3 <<PYTHON
import vim
import vimutils
from lilypath import path
from myutils import filesize
srcdir = path(vim.eval("b:musicdir"))
dstdir = path('/media/PHONE\x20CARD/Music')
srcsongs = set()
dstsongs = set()
b = vim.current.buffer

def musicselect_init():
  sizes = []
  if dstdir.exists():
    for i in dstdir.traverse():
      if i.isfile():
        dstsongs.add(str(i)[len(str(dstdir))+1:])
  else:
    vimutils.print('WarningMsg', '目标目录尚不存在')

  for i, l in enumerate(b):
    s = (srcdir+l).size
    song = l.lstrip('./')
    srcsongs.add(song)
    if song in dstsongs:
      b[i] = '*\t' + filesize(s) + '\t' + song
    else:
      b[i] = '\t' + filesize(s) + '\t' + song
    sizes.append(s)
  vim.command("let b:sizes = " + repr(sizes))

musicselect_init()
PYTHON
  let b:m = matchadd("PreProc", '^\*\s.*$')
  let b:totalsize = 0
  nnoremap <buffer> <silent> <Space> :call <SID>ToggleItem("j")<CR>
  nnoremap <buffer> <silent> <S-Space> :call <SID>ToggleItem("k")<CR>
  setlocal nomodifiable
  command! -buffer Run call <SID>syncmusic()
endfunction
" ---------------------------------------------------------------------
function! s:ToggleItem(jork)
  setlocal modifiable
  if getline('.')[0] == '*'
    let b:totalsize -= b:sizes[line('.')-1]
    call <SID>showTotalSize()
    exec "normal! 0gr\<Space>" . a:jork
  else
    let b:totalsize += b:sizes[line('.')-1]
    call <SID>showTotalSize()
    exec "normal! 0gr*" . a:jork
  endif
  setlocal nomodifiable
endfunction
" ---------------------------------------------------------------------
function! s:showTotalSize()
  py3 <<PYTHON
import os
m = os.statvfs('/media/PHONE\x20CARD')
vim.command('let &l:stl = "Music size added: %s, total free space: %s"' % (filesize(int(vim.eval('b:totalsize'))),
  filesize(m.f_bavail * m.f_bsize)))
del m
PYTHON
endfunction
" ---------------------------------------------------------------------
function! s:syncmusic()
  py3 <<PYTHON
def musicselect_sync():
  selected = set()
  for i in b:
    sel, _, song = i.split('\t')
    if sel == '*':
      selected.add(song)
  new = selected - dstsongs
  deleted = dstsongs - selected
  if new:
    vimutils.print('Title', '-- 加入手机 --')
    for i in new:
      print(i)
  if deleted:
    vimutils.print('Title', '-- 从手机删除 --')
    for i in deleted:
      print(i)
  ans = vimutils.input('确定执行操作吗？', 'Question')
  if ans in 'Yy':
    print('将在后台完成任务。')
    for i in deleted:
      (dstdir+i).unlink()

    import subprocess
    p = subprocess.Popen(('musicconvert', str(srcdir), str(dstdir)), stdin=subprocess.PIPE)
    if p.poll():
      vimutils.print('ErrorMsg', 'musicconvert 执行失败，返回值 %d' % p.returncode)
      return
    for i in new:
      p.stdin.write(i.encode()+b'\n')
    p.stdin.close()
  else:
    print('放弃操作。')

if dstdir.exists():
  musicselect_sync()
else:
  vimutils.print('ErrorMsg', '目标目录 %s 不存在！' % dstdir)
PYTHON
endfunction
" ---------------------------------------------------------------------
call s:setup()
" ---------------------------------------------------------------------
" Vim Modeline:
" vim:et:fdm=expr:fde=getline(v\:lnum-1)=~'\\v"\\s*-{20,}'?'>1'\:1
" ---------------------------------------------------------------------
