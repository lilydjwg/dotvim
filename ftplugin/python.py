# vim:fileencoding=utf-8

import vim
import sys

def EvaluateCurrentRange():
  '''执行范围内的代码'''
  eval(compile('\n'.join(vim.current.range),'','exec'),globals())

def getpath():
  path = sys.path[:]
  if '' in path:
    i = path.index('')
    paths[i] = '.'
  return path

vim.command('setlocal path=%s' % ','.join(getpath()).replace(' ', r'\ '))

