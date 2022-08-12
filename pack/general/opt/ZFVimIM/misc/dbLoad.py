import io
import json
import sys

import dbFunc


DB_FILE = sys.argv[1]
DB_COUNT_FILE = sys.argv[2]
DB_LOAD_CACHE_PATH = sys.argv[3]


pyMap = dbFunc.dbLoadPy(DB_FILE, DB_COUNT_FILE)

for c_ in range(ord('a'), ord('z') + 1):
    c = chr(c_)
    cMap = pyMap.get(c, {})
    if len(cMap) <= 0:
        continue
    with io.open(DB_LOAD_CACHE_PATH + '_' + c, 'wb') as file:
        lines = []
        for key,dbItemEncoded in sorted(dbFunc.dbMapIter(cMap)):
            lines.append(dbItemEncoded)
            if len(lines) >= dbFunc.DB_FILE_LINE_BUFFER:
                file.write(('\n'.join(lines) + '\n').encode('utf-8'))
                lines = []
        if len(lines) > 0:
            file.write(('\n'.join(lines) + '\n').encode('utf-8'))
            lines = []

