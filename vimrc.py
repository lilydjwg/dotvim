import vim
import sys
import subprocess

def echon(text):
  vim.command('echon %r' % text)

def LilyPaste():
  msg = 'Pasting...'
  echon(msg)
  vim.command('redraw')
  curl = subprocess.Popen(['curl', '--compressed', '-m', '60', '-Ss', '-F', 'vimcn=<-', 'http://p.vim-cn.com'],
                          stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                         )
  for l in vim.current.range:
    curl.stdin.write(l.encode('utf-8') + b'\n')
  curl.stdin.close()
  url = curl.stdout.read().decode('utf-8').strip()
  if not url:
    vimprint('Error', 'Failed to paste code.')
  ft = vim.eval('&ft')
  if ft:
    url = '%s/%s' % (url, ft)
  try:
    vim.eval('setreg("*", %r)' % url)
  except vim.error:
    # clipboard not supported
    pass
  echon(msg + url)
  curl.wait()

def vimprint(style, text):
  vim.command("echohl %s | echo '%s' | echohl None" % (style, text.replace("'", "''")))
