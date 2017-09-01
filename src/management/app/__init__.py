from flask import Flask
from .manager import manager
from loginapp.loginmdl import AddLoginBluePrint

app = Flask(__name__)

AddLoginBluePrint(app)

app.register_blueprint(manager)
