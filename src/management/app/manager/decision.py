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

def post_add():
    return sql_rule_common_insert("t_decisions")

def post_modify():
    return sql_rule_common_update("t_decisions")
    # print data

def post_delete():
    return sql_rule_common_delete("t_decisions")

class decisioncols(Resource):
    def get(self):
        cnx = get_cnx('userruledb')

        rules = {}

        rules['cols'] = ['ID', 'name', 'category']
        rules['datas'] = []

        with cnx.cursor() as cur:
            n = cur.execute('select id, name, category from t_decisions')
            for _ in range(n):
                row = cur.fetchone()
                if row is None:
                    break

                (_id, name,category) = row
                item = {'ID': _id, 'name':name, 'category':category}
                rules['datas'].append(item)

        return jsonify(get_error(ErrCode.OK, data=rules)) 

    def post(self):
        action = request.args.get('a')
        if (action == 'mdf'):
            return post_modify()
        elif  (action == 'add'):
            return post_add()
        elif (action == 'del'):
            return post_delete()

        return  jsonify(get_error(ErrCode.INVALID_PARAMETER))


class decisions(Resource):
    def get(self):
        cnx = get_cnx('userruledb')

        decisions = []

        with cnx.cursor() as cur:
            n = cur.execute('select id, name, abusetype from t_decisions')
            for _ in range(n):
                row = cur.fetchone()
                if row is None:
                    break

                (_id, name,abusetype) = row
                item = {'ID': _id, 'name':name, 'abusetype':abusetype}
                decisions.append(item)

        return jsonify(get_error(ErrCode.OK, data=decisions)) 

