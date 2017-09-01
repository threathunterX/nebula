# -*- coding: utf-8 -*-
from flask import request, jsonify
from flask_restful import Resource
from . import manager, get_cnx
from .errorcode import json_error, ErrCode
from .utils import sql_rule_common_insert, sql_rule_common_update, sql_rule_common_delete, get_update_sql_by_json
from loginapp.mysecurity.flask_security import current_user
from loginapp.mysecurity.flask_security import login_required, roles_accepted
from pymongo import MongoClient
from config import dbconf
from common import QuickSQL
from datetime import datetime
from collections import defaultdict
from common import getYmd, Ymds, Yms, getYm, MYSQL

mdb_client = MongoClient('localhost', 27017)
db = mdb_client.db_mp_log;

class actionlogs(Resource):
  def get(self):
    # $.getJSON("/management/data/analyze/actionlogs", function(d){console.log(d)})
    rules = {}

    rules['cols'] = ['decision', 'user', 'detail']
    rules['datas'] = []

    for log in db.decisionlog.find(projection={"_id":0}):
      item = {'decision':log['decision']['name'],  'user':log['baseinfo']['email'], 'detail':log }
      rules['datas'].append(item)

    return json_error(200, data=rules)
    # cnx = get_cnx('userruledb')

    # rules = []
    # busiidarg = request.args.get('busiid')

    # with cnx.cursor() as cur:
    #     sql = 'select id, ftype, period, fdata, maxfreq, active from t_frequency'
    #     if busiidarg != None:
    #         sql += ' where businessid = %s' % busiidarg

    #     n = cur.execute(sql)
    #     for _ in range(n):
    #         row = cur.fetchone()
    #         if row is None:
    #             break

    #         _id, ftype, period, fdata, maxfreq, active = row
    #         item = {'ID':_id, 'ftype':ftype, "fdata":fdata, "maxfreq":maxfreq, "active":active, "period":period}
    #         rules.append(item)

    # return jsonify(get_error(ErrCode.OK, data=rules))

class actionlogs_chart(Resource):
  # $.getJSON("/management/data/analyze/actionlogs/chart", function(d){console.log(d)})
  def get(self):

      
      decision_names = db.decisionlog.distinct("decision.name")

      delta_day = 20

      fmt_time = getYmd(-delta_day, "%Y-%m-%d")
      days = Ymds(getYmd(-delta_day, "%Y-%m-%d"), getYmd(0, "%Y-%m-%d"), "%Y-%m-%d")
      idata = defaultdict(lambda :[{'time': day, 'value': 0} for day in days])
     
      ddata = []

      for name in decision_names:
        group = db.decisionlog.aggregate([{'$match':{'decision.name':name}},{'$group' : {'_id' : "$date", 'num_tutorial' : {'$sum': 1}}}])
        logs = list(group)

        dictrule = idata[name]
        for row in logs:
          for x in dictrule:
            if x['time'] == row['_id']:
                x['value'] = int(row['num_tutorial'])

      for x, v in idata.iteritems():
        ddata.append({x:v})

      ddata.sort()
      return json_error(200, data=ddata)
