# -*- coding: utf-8 -*-
from flask import request, jsonify
from . import manager, get_cnx
from .errorcode import get_error, ErrCode
from .utils import sql_rule_common_insert, sql_rule_common_update, sql_rule_common_delete
from loginapp.mysecurity.flask_security import current_user
from loginapp.mysecurity.flask_security import login_required, roles_accepted

@login_required
def GET():
    cnx = get_cnx('userruledb')

    with cnx.cursor() as cur:
        n = cur.execute('select email, confirmed_at from t_admin_user  where email="%s" limit 1 ' % current_user)
        row = cur.fetchone()
        if row is None:
            return jsonify(get_error(ErrCode.UserNotFind))

        email, confirmed_at = row
        confirmdate = confirmed_at.strftime('%b %d. %Y') if confirmed_at is not None else "null"
        item = {'email':email, 'confirmed_at':confirmdate}
        return jsonify(get_error(ErrCode.OK, data=item))

    return jsonify(get_error(ErrCode.UNKNOWN))

@login_required
def POST():
    pass

@manager.route('/management/data/logininfo', methods=['GET', 'POST'])
def logininfo():
    return {'GET': GET, 'POST': POST}[request.method]()