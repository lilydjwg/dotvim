#!/usr/bin/env python3
# vim:fileencoding=utf-8

import sys
import io
import token, tokenize

default = 2

def setsw(stream):
  sw = default
  try:
    sw = min(len(x.string) for x in tokenize.tokenize(stream.readline) if x.type == token.INDENT)
  except (ValueError, SyntaxError):
    pass
  print(sw)

if __name__ == '__main__':
  try:
    with open(sys.argv[1], 'rb') as f:
      setsw(f)
  except (IOError, OSError):
    print(default)
