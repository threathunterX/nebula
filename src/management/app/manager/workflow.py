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

QS = QuickSQL()

class workflows(Resource):
    # $.getJSON("/management/data/workflows", function(d){console.log(d)})
    def get(self):
        cnx = get_cnx('userruledb')
        sql = ' select id, name, event, affecting, status from t_workflows';
        rs = QS.query(dbconf('userruledb'), sql) or []
        return json_error(200, data=rs)

    '''$.ajax({
      url: "/management/data/workflows",
      type: 'POST',
      contentType: 'application/json',
      data: JSON.stringify({'name':'workflow', 'event':'login', 'affecting':'user'}),
      success : function(data) {
        console.log(data)
      }
    });'''
    def post(self):
        cnx = get_cnx('userruledb')
        json = request.json

        response_id = 0
        sql = u"insert into t_workflows set name='{}', event='{}', affecting='{}'".format(json['name'], json['event'], 'user')

        with cnx.cursor() as cur:
            cur.execute(sql)
            cnx.commit()
            print "ID of inserted record is ", int(cur.lastrowid)
            response_id = cur.lastrowid

        return json_error(201, data={'id':response_id})
        
class workflow(Resource):
    # $.getJSON("/management/data/workflows/1", function(d){console.log(d)})
    def get(self, _id):
        cnx = get_cnx('userruledb')
        sql = ' select id, name, event, affecting, status from t_workflows where id = {}'.format(_id);
        rs = QS.query(dbconf('userruledb'), sql) or []
        if len(rs) == 0:
            return json_error(404)

        return json_error(200, data=rs)

    '''$.ajax({
      url: "/management/data/workflows/3",
      type: 'PUT',
      contentType: 'application/json',
      data: JSON.stringify({'name':'update_workflow', 'event':'login', 'affecting':'user'}),
      success : function(data) {
        console.log(data)
      }
    });'''
    def put(self, _id):
        json = request.json
        sql = "select id from t_workflows where id = {}".format(_id)
        rs = QS.query(dbconf('userruledb'), sql) or []
        if len(rs) == 0:
            return json_error(404)

        updatesql = get_update_sql_by_json('t_workflows', json, _id)
        rs = QS.query(dbconf('userruledb'), updatesql)
        print 'rs:',rs
        
        return json_error(200)

    '''$.ajax({
      url: "/management/data/workflows/2",
      type: 'DELETE',
      success : function(data) {
        console.log(data)
      }
    });
    '''
    def delete(self, _id):
        sql = "select id from t_workflows where id = {}".format(_id)
        rs = QS.query(dbconf('userruledb'), sql) or []
        if len(rs) == 0:
            return json_error(404)

        sql = "delete from t_routes where workflowid={}".format(_id)
        QS.query(dbconf('userruledb'), sql)

        json = request.json
        sql = "delete from t_workflows where id = {}".format(_id)
        QS.query(dbconf('userruledb'), sql)
        return json_error(200)


class workflow_routes(Resource):
    # $.getJSON("/management/data/workflows/1/routes", function(d){console.log(d)})
    def get(self, _id):
        sql = "select * from t_workflows where id = {}".format(_id)
        rs = QS.query(dbconf('userruledb'), sql) or []
        if len(rs) == 0:
            return json_error(404)

        sql = "select id, workflowid, criterias, action, reviewid, decisionid from t_routes where workflowid = {} ".format(_id)
        rs = QS.query(dbconf('userruledb'), sql) or []
        return json_error(200, data=rs)
