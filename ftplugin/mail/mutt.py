#python3

import vim
import re
import functools
import json

_re_mailaddr = re.compile(r'''
  (?P<quote>"?)
  (?P<name>(?(quote)[^"]+|\S+))
  (?P=quote)
  \s+
  <
    (?P<addr>[^>]+)
  >
''', re.X)

mail_config = json.load(open(vim.eval('g:MuttVim_configfile')))

def mail_doAtHeader(header):
  header = header + ': '
  def w(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
      b = vim.current.buffer
      for index, l in enumerate(b):
        if l.startswith(header):
          value = l[len(header):].strip()
          return func(b, index, value, *args, **kwargs)
        elif not l:
          break
    return wrapper
  return w

@mail_doAtHeader('To')
def mail_getTo(buf, index, value):
  m = _re_mailaddr.match(value)
  if m:
    return m.group('name'), m.group('addr')
  else:
    return None, value

@mail_doAtHeader('Subject')
def mail_getSubject(buf, index, value):
  return value

@mail_doAtHeader('From')
def mail_changeFrom(buf, index, value, name=None, addr=None):
  if not (name and addr):
    m = _re_mailaddr.match(value)
  if addr is None:
    if m:
      addr = m.group('addr')
    else:
      addr = value
  if name is None and m:
    name = m.group('name')
  if not name:
    l = 'From: ' + addr
  else:
    if name.find(' ') != -1:
      name = '"%s"' % name
    l = 'From: %s <%s>' % (name, addr)
  buf[index] = l

@mail_doAtHeader('Cc')
def mail_addCc(buf, index, value, mailaddr):
  if value:
    ccs = {x.strip() for x in value.split(',')}
  else:
    ccs = set()
  ccs.update(mailaddr)
  buf[index] = 'Cc: '+ ', '.join(ccs)

def procMuttMail():
  name, mail = mail_getTo()
  sub = None
  for rule in mail_config:
    matched = False
    for k, v in rule['match'].items():
      if k == 'name':
        matched = name in v
      elif k == 'mail':
        matched = mail in v
      elif k == 'subject':
        if sub is None:
          sub = mail_getSubject()
        matched = sub in v
      elif k == 'mail_re':
        matched = re.search(v, mail) is not None
      else:
        vimprint('ErrorMsg', 'Undefined match rule: '+k)
      if matched:
        for k, v in rule['action'].items():
          if k == 'from_name':
            mail_changeFrom(name=v)
          elif k == 'from_mail':
            mail_changeFrom(addr=v)
          elif k == 'addcc':
            mail_addCc(v)
          else:
            vimprint('ErrorMsg', 'Undefined match action: '+k)
