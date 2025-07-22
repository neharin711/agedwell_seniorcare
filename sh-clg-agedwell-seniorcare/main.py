from flask import Flask
from public import public
from admin import admin
from api import api

import smtplib
from email.mime.text import MIMEText
from flask_mail import Mail

ok=Flask(__name__)

ok.secret_key="itssecret"

ok.config['MAIL_SERVER'] = 'smtp.gmail.com'
ok.config['MAIL_PORT'] = 587
ok.config['MAIL_USERNAME'] = 'hariharan0987pp@gmail.com'
ok.config['MAIL_PASSWORD'] = 'rjcbcumvkpqynpep'  # Consider using an app-specific password
ok.config['MAIL_USE_TLS'] = True
ok.config['MAIL_USE_SSL'] = False

mail = Mail(ok)



ok.register_blueprint(public)
ok.register_blueprint(admin,url_prefix='/admin')
ok.register_blueprint(api,url_prefix='/api')


ok.run(debug=True,port=5346,host="0.0.0.0")