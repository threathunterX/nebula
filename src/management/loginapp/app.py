from flask import Flask, render_template
from flask_mail import Mail, Message
from loginmdl import AddLoginBluePrint, db
from flask_sqlalchemy import SQLAlchemy
import sys
sys.path.insert(0, ".")
from mysecurity.flask_security import login_required

# Create app
app = Flask(__name__)

# Views
@app.route('/')
@login_required
def home():
    return render_template('index.html')

@app.route('/index')
@login_required
def home2():
    return render_template('index.html')

def BuildSampleDB():
    with app.app_context():
        #db.drop_all()
        db.create_all()


if __name__ == '__main__':

    AddLoginBluePrint(app)
    BuildSampleDB()
#    app.run("0.0.0.0", debug=True)
