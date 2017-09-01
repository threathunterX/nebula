# -*- coding: utf8 -*-

import time
from datetime import datetime, timedelta
import calendar

strptime = datetime.strptime

def Yms(startYm, endYm, tfmt="%Y%m"):
    '''Get "Ym" from startYm to endYm.
    e.g.
        startYm, endYm = "201512", "201607"
        Yms(startYm, endYm) -> ["201512", "201601" ... "201607"]
    '''
    start, end = [strptime(t, tfmt) for t in startYm, endYm]
    startY, endY = start.year, end.year
    assert (endY - startY) in (0, 1)
    startM, endM = start.month, end.month
    Ms = ['01', '02', '03', '04',   
    '05', '06', '07', '08',
    '09', '10', '11', '12',]
    if endY - startY:
        YMstart = [str(startY) + M for M in Ms[startM-1:]]
        YMend = [str(endY) + M for M in Ms[:endM]]
        return YMstart + YMend
    return [str(endY) + M for M in Ms[startM-1:endM]] 

def Ymds(startYmd, endYmd, tfmt="%Y%m%d"):
    '''Get "Ymd" from startYmd to endYmd.
    e.g
        startYmd, endYmd = "20151226", "20160117"
        Ymd(startYmd, endYmd) -> ["20151226", "20151227" ... "20160117"]
    '''
    start, end = [strptime(t, tfmt) for t in startYmd, endYmd]
    dlt = end - start
    assert dlt.days >= 0
    trange = (start + timedelta(days=d) for d in xrange(dlt.days+1))
    Ymds = (t.strftime(tfmt) for t in trange)
    return [Ymd for Ymd in Ymds]

def getYm(delta=0, tfmt="%Y%m"):
    dt = datetime.now()
    _delta = abs(delta)
    while _delta > 0:
        if delta > 0:
            monthday = calendar.monthrange(dt.year,dt.month)[1]
            _days = monthday - dt.day + 1
        else:            
            _days = -dt.day
        dt += timedelta(days=_days)
        _delta -= 1
    return dt.strftime(tfmt)

def getYmd(delta=0, tfmt="%Y%m%d"):
    return (datetime.now() + timedelta(days=delta)).strftime(tfmt)

class UnixTime():
    def now(self):
        return hex(int(time.time()))[2:]

    def fromTime(self, datestr, fmt='%Y-%m-%d %H:%M:%S'):
        return hex(int(time.mktime(time.strptime(datestr, fmt))))[2:]

    def toTime(self, hextime, fmt='%Y-%m-%d %H:%M:%S'):
        return time.strftime(fmt, time.localtime(int(str(hextime), 16)))

if __name__ == '__main__':
    for Ym in Yms("201512", "201607"): print Ym
    print '\n'
    for Ym in Yms("201607", "201607"): print Ym
    print '\n'
    for Ymd in Ymds("20151226", "20160117"): print Ymd
    print '\n'
    for Ymd in Ymds("20160117", "20160117"): print Ymd
    print '\n'

    print getYm(), getYm(5), getYm(-5)
    print getYmd(), getYmd(5), getYmd(-5)
    print ''

    UT = UnixTime()
    print UT.now()
    print UT.toTime('58785060')
    print UT.fromTime('2017-01-13 11:58:24')
