
userruledb = {
    'user': 'maliciousrwuser',
    'host': '127.0.0.1',
    'password' : '123456', 
    'port': 3306,
    'charset': 'utf8',
    'db': 'db_mp_conf'
}

preventlogdb = {
    'user': 'maliciousrwuser',
    'host': '127.0.0.1',
    'password' : '123456', 
    'port': 3306,
    'charset': 'utf8',
    'db': 'db_mp_preventlog'
}

ruleredisdb = {
        'host': '127.0.0.1',
        'db': 2,
        'port': 6379
        }

cnfmap = {
    'userruledb': userruledb,
    'rulerds':ruleredisdb,
    'preventlogdb':preventlogdb
}

dbconf = lambda nm: cnfmap[nm]
