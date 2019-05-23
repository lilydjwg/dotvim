import vim
import subprocess
import shlex
import enum

class EchoKind(enum.Enum):
  normal = 'echo'
  echon = 'echon'
  msg = 'echomsg'

def LilyPaste():
  msg = 'Pasting...'
  vimprint(msg)
  vim.command('redraw')
  curl = subprocess.Popen(
    ['curl', '--compressed', '-m', '60', '-Ss', '-F', 'vimcn=<-', 'https://cfp.vim-cn.com'],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE,
  )
  for l in vim.current.range:
    curl.stdin.write(l.encode('utf-8') + b'\n')
  curl.stdin.close()
  url = curl.stdout.read().decode('utf-8').strip()
  if not url:
    vimprint('ErrorMsg', 'Failed to paste code.')
  ft = vim.eval('&ft')
  if ft:
    url = '%s/%s' % (url, ft)
  try:
    vim.eval('setreg("*", %r)' % url)
  except vim.error:
    # clipboard not supported
    pass
  vimprint(msg, kind=EchoKind.echon)
  vimprint(url, style='Underlined', kind=EchoKind.echon)
  curl.wait()

def vimprint(text, *, style='Normal', kind=EchoKind.normal):
  echo = kind.value
  vim.command("echohl {style} | {echo} '{text}' | echohl None".format(
    style = style,
    text = text.replace("'", "''"),
    echo = echo,
  ))

def LilyQw(s):
  if s[-1] == ')':
    s = s[:-1]
  try:
    return repr(shlex.split(s))[1:-1]
  except ValueError as e:
    vimprint(str(e), style='ErrorMsg')
    vim.command('call getchar()')
  return ''
