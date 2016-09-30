#!/usr/bin/env python3
# vim:fileencoding=utf-8

import sys
import io
import token, tokenize

def setsw(stream):
  sw = 2
  try:
    sw = min(len(x.string) for x in tokenize.tokenize(stream.readline) if x.type == token.INDENT)
  except (ValueError, SyntaxError):
    pass
  print(sw)

if __name__ == '__main__':
  with open(sys.argv[1], 'rb') as f:
    setsw(f)
