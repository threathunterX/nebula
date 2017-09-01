from flask import request, jsonify
from . import manager, get_cnx
from .errorcode import get_error, ErrCode

def sql_rule_common_insert(tablename, **arg):
    cnx = get_cnx('userruledb')
    data = request.json
    print "post_add json: ",data

    sqlsets = []
    for k,v in data.items():
        if (k == 'id'):
            continue;

        sqlsets.append( "=".join(['`'+k+'`','"'+v+'"']))

    for karg,varg in arg.items():
        sqlsets.append( "=".join(['`'+karg+'`','"'+str(varg)+'"']))

    sql = "insert into " + tablename + " set " + ",".join(sqlsets)
    print "sql: " + sql

    with cnx.cursor() as cur:
        cur.execute(sql)
        cnx.commit()

        return jsonify(get_error(ErrCode.OK))


def sql_rule_common_update(tablename):
    cnx = get_cnx('userruledb')
    data = request.json
    print "post_modify json: ",data

    _id = data['id']
    sqlsets = []
    for k,v in data.items():
        if (k == _id):
            continue
        sqlsets.append( "=".join(['`'+k+'`','"'+v+'"']))

    sql = "update " + tablename + " set " + ",".join(sqlsets) + " where id=%s" % _id
    print "sql: " + sql

    with cnx.cursor() as cur:
        cur.execute(sql)
        cnx.commit()

        return jsonify(get_error(ErrCode.OK))

    # print data

def sql_rule_common_delete(tablename):
    cnx = get_cnx('userruledb')
    data = request.json
    print "post_delete json: ",data

    _id = data['id']
    
    sql = "delete from " + tablename + " where id=%s" % _id
    print "sql: " + sql

    with cnx.cursor() as cur:
        cur.execute(sql)
        cnx.commit()

        return jsonify(get_error(ErrCode.OK))

def get_update_sql_by_json(tablename, kvjson, _id):
    sqlsets = []
    for k,v in kvjson.items():
        if (k == 'id'):
            continue
        sqlsets.append( "=".join(['`'+k+'`','"'+str(v)+'"']))

    sql = "update " + tablename + " set " + ",".join(sqlsets) + " where id={}".format(_id)

    return sql
    