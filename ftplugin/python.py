# vim:fileencoding=utf-8
# NOTE: No Chinese here to avoid unable to decode when 'encoding' and
# 'fileencoding' differs

import vim
import sys
import io
import token, tokenize

def EvaluateCurrentRange():
  eval(compile('\n'.join(vim.current.range),'','exec'),globals())

def getpath():
  path = sys.path[:]
  if '' in path:
    i = path.index('')
    paths[i] = '.'
  return path

vim.command('setlocal path=%s' % '.,'+','.join(getpath()).replace(' ', r'\ '))

def setsw():
  try:
    stream = io.BytesIO('\n'.join(vim.current.buffer).encode(vim.eval('&fenc')))
  except LookupError:
    return
  try:
    sw = min(len(x.string) for x in tokenize.tokenize(stream.readline) if x.type == token.INDENT)
  except (ValueError, SyntaxError):
    return
  vim.command('setlocal sw=%d' % sw)

setsw()
