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

QS = QuickSQL()

class routes(Resource):
  # $.getJSON("/management/data/routes", function(d){console.log(d)})
  def get(self):
      cnx = get_cnx('userruledb')
      sql = ' select id, workflowid, criterias, action, reviewid, decisionid from t_routes';
      rs = QS.query(dbconf('userruledb'), sql) or []
      return json_error(200, data=rs)

  '''$.ajax({
    url: "/management/data/routes",
    type: 'POST',
    contentType: 'application/json',
    data: JSON.stringify({'workflowid':11, 'criterias':'$user.ip_try_user_cnt > 100 && $user.ip_try_user_cnt < 1000 && $user.phone_risk_level = 9', 'decisionid':999}),
    success : function(data) {
      console.log(data)
    }
  });'''
  def post(self):
      cnx = get_cnx('userruledb')
      json = request.json

      response_id = 0
      workflowid = json['workflowid']

      rs = QS.query(dbconf('userruledb'), 'select * from t_workflows where id = {}'.format(workflowid), True) or []
      if len(rs) == 0:
          return json_error(404)



      sql = u"insert into t_routes set workflowid='{}', criterias='{}', action='{}', reviewid='{}', decisionid='{}'".format(
          workflowid, 
          json['criterias'] if json.has_key('criterias') else '', 
          '2', 
          '0', 
          json['decisionid'] if json.has_key('decisionid') else '0')

      with cnx.cursor() as cur:
          cur.execute(sql)
          cnx.commit()
          print "ID of inserted record is ", int(cur.lastrowid)
          response_id = cur.lastrowid

      # if len(rs['routes']) == 0:
      #   routesstr = str(response_id)
      # else:
      #   routeslist = rs['routes'].split(',')
      #   routeslist.append(str(response_id))
      #   routesstr = ','.join(routeslist)
      # updatesql = 'update t_workflows set routes = "{}" where id = {}'.format(routesstr, workflowid)
      # QS.query(dbconf('userruledb'), updatesql)

      return json_error(201, data={'id':response_id})

class route(Resource):
  # $.getJSON("/management/data/routes/1", function(d){console.log(d)})
  def get(self, _id):
      cnx = get_cnx('userruledb')
      sql = ' select id, workflowid, criterias, action, reviewid, decisionid from t_routes where id = {}'.format(_id);
      rs = QS.query(dbconf('userruledb'), sql) or []
      if len(rs) == 0:
          return json_error(404)

      return json_error(200, data=rs)

  '''$.ajax({
    url: "/management/data/routes/2",
    type: 'PUT',
    contentType: 'application/json',
    data: JSON.stringify({'workflowid':1, 'criterias':'update criteria', 'decisionid':999}),
    success : function(data) {
      console.log(data)
    }
  });'''
  def put(self, _id):
      json = request.json
      sql = "select id from t_routes where id = {}".format(_id)
      rs = QS.query(dbconf('userruledb'), sql) or []
      if len(rs) == 0:
          return json_error(404)

      updatesql = get_update_sql_by_json('t_routes', json, _id)
      rs = QS.query(dbconf('userruledb'), updatesql)
      print 'rs:',rs
      
      return json_error(200)

  '''$.ajax({
    url: "/management/data/routes/2",
    type: 'DELETE',
    success : function(data) {
      console.log(data)
    }
  });
  '''
  def delete(self, _id):
      sql = "select id from t_routes where id = {}".format(_id)
      rs = QS.query(dbconf('userruledb'), sql) or []
      if len(rs) == 0:
          return json_error(404)

      json = request.json
      sql = "delete from t_routes where id = {}".format(_id)
      QS.query(dbconf('userruledb'), sql)
      return json_error(200)

class rules(Resource):
  def get(self):
    '''$.getJSON("/management/data/rules", function(d){console.log(d)})'''
    cnx = get_cnx('userruledb')

    facts = []

    ops = []
    ops.append({'op':'<'})
    ops.append({'op':'<='})
    ops.append({'op':'>'})
    ops.append({'op':'>='})
    ops.append({'op':'=='})
    ops.append({'op':'!='})
    ops.append({'op':'is'})

    with cnx.cursor() as cur:
        n = cur.execute('select fact from t_rule_facts order by fact')
        for _ in range(n):
            row = cur.fetchone()
            if row is None:
                break

            (fact,) = row
            item = {'fact':fact, 'ops':ops}
            facts.append(item)
            
    return json_error(200,data=facts)