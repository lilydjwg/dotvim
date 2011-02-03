# vim:fileencoding=utf-8
# NOTE: No Chinese here to avoid unable to decode when 'encoding' and
# 'fileencoding' differs

import vim
import sys

def EvaluateCurrentRange():
  eval(compile('\n'.join(vim.current.range),'','exec'),globals())

def getpath():
  path = sys.path[:]
  if '' in path:
    i = path.index('')
    paths[i] = '.'
  return path

vim.command('setlocal path=%s' % ','.join(getpath()).replace(' ', r'\ '))

