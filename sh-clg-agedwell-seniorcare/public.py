from flask import *
from database import *
from flask_mail import *


public=Blueprint('/public',__name__)



@public.route('/')
def home():
    return render_template('/home.html')

@public.route('/login', methods=['GET', 'POST'])
def login():
    session.clear() 
    if 'login' in request.form:
        username = request.form['username']
        password = request.form['password']

        query="SELECT * FROM login WHERE username='%s' AND password='%s'"%(username, password)
        res=select(query)
        if res:
            session['login_id'] = res[0]['login_id']
            session['lid']=res[0]['login_id']
            if res[0]['usertype'] == "admin":
                flash("WELCOME ADMIN")
                return redirect(url_for('admin.admin_home'))
    return render_template('/login.html')




