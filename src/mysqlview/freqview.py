#!/bin/python
#-*-coding=utf-8-*-

from libmysql import MYSQL

logdbconf = {
        "host":"127.0.0.1",
        "port":3306,
        "user":"maliciousrwuser",
        "password":"123456",
        "db":"db_mp_freqlog"
    }

dbHandle  = MYSQL(logdbconf)

# sip, dev, user dimension of frequency
# if the request if very huge, should use redis to cache
def CreateView():
    # drop view if exists sip_freq_view
    # drop view if exists dev_freq_view
    # drop view if exists user_freq_view
    # create view sip_freq_view as select sip,count(1) as cnt from t_frequency_campaign where rtime > "2017-07-08" group by sip;
    # create view dev_freq_view as select sip,count(1) as cnt from t_frequency_campaign where rtime > "2017-07-08" group by sip;
    # create view user_freq_view as select sip,count(1) as cnt from t_frequency_campaign where rtime > "2017-07-08" group by sip;
    sqlstr = "drop view if exists sip_freq_view"
    res = dbHandle.execute(sqlstr)
    print res

    res = dbHandle.execute("create view sip_freq_view as select sip,count(1) as cnt from t_frequency_campaign group by sip")
    print res

    sqlstr = "drop view if exists dev_freq_view"
    res = dbHandle.execute(sqlstr)
    print res

    res = dbHandle.execute("create view dev_freq_view as select devid,count(1) as cnt from t_frequency_campaign group by devid")
    print res

    sqlstr = "drop view if exists user_freq_view"
    res = dbHandle.execute(sqlstr)
    print res

    res = dbHandle.execute("create view user_freq_view as select user,count(1) as cnt from t_frequency_campaign group by user")
    print res


if __name__ == "__main__":
    CreateView()
