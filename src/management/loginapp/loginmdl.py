from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import redis
import sys
import os
sys.path.insert(0, ".")
from mysession.flask_session import Session
from mysecurity.flask_security import login_required
from mysecurity.flask_security import Security, SQLAlchemyUserDatastore, \
    UserMixin, RoleMixin, login_required, current_user
from mysecurity.flask_security.utils import encrypt_password
from flask_mail import Mail

db = SQLAlchemy()



CONF_FILE= os.path.join( os.path.dirname(os.path.realpath(__file__)), "loginconf.py")

# Define models
roles_users = db.Table(
    't_admin_roles_users',
    db.Column('user_id', db.Integer(), db.ForeignKey('t_admin_user.id')),
    db.Column('role_id', db.Integer(), db.ForeignKey('t_admin_role.id'))
)

class Role(db.Model, RoleMixin):
    __tablename__ = "t_admin_role"
    id = db.Column(db.Integer(), primary_key=True)
    name = db.Column(db.String(80), unique=True)
    description = db.Column(db.String(255))

    def __str__(self):
        return self.name


class User(db.Model, UserMixin):
    __tablename__ = "t_admin_user"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64))
    email = db.Column(db.String(255), unique=True)
    phoneno = db.Column(db.String(16))
    company = db.Column(db.String(128))
    password = db.Column(db.String(255))
    active = db.Column(db.Boolean())
    auditflag = db.Column(db.Integer)
    confirmed_at = db.Column(db.DateTime())
    roles = db.relationship('Role', secondary=roles_users,
                            backref=db.backref('users', lazy='dynamic'))

    def __str__(self):
        return self.email

class LoginLog(db.Model):
    __tablename__ = "t_admin_user_login_log"
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(255))
    loginip = db.Column(db.String(16))
    logintime = db.Column(db.DateTime())
    loginstatus = db.Column(db.Integer)


def AddLoginBluePrint(app):
    app.config.from_pyfile(CONF_FILE)
    db.init_app(app)
    user_datastore = SQLAlchemyUserDatastore(db, User, Role, LoginLog)
    app.config['SESSION_TYPE'] = 'redis'
    app.config['SESSION_REDIS'] = redis.Redis(host='127.0.0.1', port=6379, db=2)
    app.config['PERMANENT_SESSION_LIFETIME'] = 86400

    sess = Session()
    sess.init_app(app)
    security = Security(app, user_datastore)
