from flask import Blueprint, g
from config import dbconf
from flask_restful import Resource, Api
import pymysql
import redis

manager = Blueprint('manager', __name__)
api = Api(manager)

def get_cnx(nm):
    attr = 'cnx_%s' % nm
    cnx = getattr(g, attr, None)
    if (cnx is None):
        cnf = dbconf(nm) # TBD: dbconf
        cnf["cursorclass"] = pymysql.cursors.Cursor
        _cnx = pymysql.connect(**cnf)
        setattr(g, attr, _cnx)
        return _cnx
    return cnx

def get_rds():
    attr = 'rds'
    cnx = getattr(g, attr, None)
    if cnx is None:
        cnf = dbconf(attr)
        _cnx = redis.Redis(**cnf)
        setattr(g, attr, _cnx)
        return _cnx
    return cnx

from .logininfo import logininfo
from .userrules import rulefacts, ruleops
api.add_resource(rulefacts, '/management/data/rulefacts')
api.add_resource(ruleops, '/management/data/ruleops')

from .explore import userlog
api.add_resource(userlog, '/management/data/userlog')

from .decision import decisioncols, decisions
api.add_resource(decisioncols, '/management/data/decisioncols')
api.add_resource(decisions, '/management/data/decisions')

from .workflow import workflows, workflow, workflow_routes
api.add_resource(workflows, '/management/data/workflows')
api.add_resource(workflow, '/management/data/workflows/<int:_id>')
api.add_resource(workflow_routes, '/management/data/workflows/<int:_id>/routes')

from .routes import routes, route, rules
api.add_resource(routes, '/management/data/routes')
api.add_resource(route, '/management/data/routes/<int:_id>')
api.add_resource(rules, '/management/data/rulefs')

from .analyze import actionlogs_chart,actionlogs
api.add_resource(actionlogs_chart, '/management/data/analyze/actionlogs/chart')
api.add_resource(actionlogs, '/management/data/analyze/actionlogs')
