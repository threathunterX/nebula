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

class userlog(Resource):
    def get(self):
        db = mdb_client.db_mp_log;

        datas = []
        for log in  db.userlog.find(projection={"_id":0}):
            datas.append(log)
            # print log


        return jsonify(get_error(ErrCode.OK, data=datas))
