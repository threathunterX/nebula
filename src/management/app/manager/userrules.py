# -*- coding: utf-8 -*-
from flask import request, jsonify
from flask_restful import Resource
from . import manager, get_cnx, api
from flask_restful import Resource
from .errorcode import get_error, ErrCode, json_error
from .utils import sql_rule_common_insert, sql_rule_common_update, sql_rule_common_delete, get_update_sql_by_json
from loginapp.mysecurity.flask_security import current_user
from loginapp.mysecurity.flask_security import login_required, roles_accepted
from pymongo import MongoClient
from config import dbconf
from common import QuickSQL

mdb_client = MongoClient('localhost', 27017)

def getDictKeys(d, prefix = '', delfirstclassKey = False):
    keys = []
    for k,v in d.items():
        key = prefix + k
        keys.append(key)
        if isinstance(v, dict):
            if delfirstclassKey:
                keys.remove(key)
            new_prefix = prefix + k + '.'
            subkeys = getDictKeys(v, new_prefix)
            keys.extend(subkeys)
    return keys

class rulefacts(Resource):
    def get(self):
        db = mdb_client.db_mp_log;

        userlog = db.userlog

        a = userlog.find_one(projection={"_id":0})    
        facts_fact = getDictKeys(a,prefix='$user.', delfirstclassKey=True)

        facts = []

        for factstr in facts_fact:
            fact = {}
            fact['fact'] = factstr
            namestr = factstr.split('.')[-1]
            fact['name'] = ' '.join(namestr.split('_'))
            facts.append(fact)     
        # cnx = get_cnx('userruledb')

        # facts = []

        # with cnx.cursor() as cur:
        #     n = cur.execute('select fact from t_rule_facts order by fact')
        #     for _ in range(n):
        #         row = cur.fetchone()
        #         if row is None:
        #             break

        #         (fact,) = row
        #         item = {'fact':fact}
        #         facts.append(item)
                
        return jsonify(get_error(ErrCode.OK, data=facts))  

class ruleops(Resource):
    def get(self):
        ops = []
        ops.append({'op':'<'})
        ops.append({'op':'<='})
        ops.append({'op':'>'})
        ops.append({'op':'>='})
        ops.append({'op':'=='})
        ops.append({'op':'!='})
        ops.append({'op':'is'})

        return jsonify(get_error(ErrCode.OK, data=ops))
