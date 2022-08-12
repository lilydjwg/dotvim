import sys

import dbFunc


DB_FILE = sys.argv[1]
CACHE_PATH = sys.argv[2]


pyMap = dbFunc.dbLoadNormalizePy(DB_FILE)
dbFunc.dbSavePy(pyMap, DB_FILE, '', CACHE_PATH)

