#!/bin/python
#-*-coding=utf-8-*-

from random import randint
from faker import Factory

from pymongo import MongoClient
mdb_client = MongoClient('localhost', 27017)

fake = Factory.create()

def fake_user_info():
    user = {
        "name": fake.name(),
        "email":fake.email(),
        "activity_time": fake.date_time_this_month(before_now=True, after_now=False, tzinfo=None).strftime("%Y-%m-%d %H:%M:%S"),
    }
    
    return user

def fake_risk_info():
    risk = {
        "API_event_without_page_view" :["true", "false"][randint(0,1)],
        "Account_Age": randint(1,50),
        "Country" : fake.country(),

        "Create_accounts_in_the_last_day":randint(1,50),
        "Create_accounts_in_the_last_hour":randint(1,50),
        "Device_fingerprint":   fake.md5(),
        "Disposable_email_domain": ["true", "false"][randint(0,1)],
        "IP_address":fake.ipv4(),
        "IP_is_Proxy":["true", "false"][randint(0,1)],


    }
    return risk

def produce_explore_datas(cnt):

    datas = []
    for i in range(cnt):
        data = {
            "scores": randint(1,100),
            "baseinfo": fake_user_info(),
            "riskinfo": fake_risk_info()
            }
        datas.append(data)

    return datas

def insert_explore_date_in_mongodb(datas):
    db = mdb_client.db_mp_log;
    result = db.userlog.insert_many(datas)
    print "insert mongodb result:", result.inserted_ids

if __name__ == '__main__':
    datas = produce_explore_datas(100)
    
    print datas

    insert_explore_date_in_mongodb(datas)


    
