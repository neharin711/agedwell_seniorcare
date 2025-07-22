from flask import *
from database import*
import uuid
import smtplib
from email.mime.text import MIMEText
from flask_mail import Mail

admin=Blueprint('admin',__name__)

@admin.route('/admin_home',methods=['get','post'])
def admin_home():

    return render_template('admin_home.html')


@admin.route('/admin_view_food_request', methods=['POST', 'GET'])
def admin_view_food_request():
    data = {}

    action = request.args.get('action')
    food_request_id = request.args.get('id')

    if action == 'reject' and food_request_id:
        q = f"DELETE FROM food_request WHERE food_request_id = '{food_request_id}'"
        delete(q)
        return redirect(url_for('admin.admin_view_food_request'))

    if action == "accept" and food_request_id:
        update_status_query = f"UPDATE food_request SET status = 'accepted' WHERE food_request_id = '{food_request_id}'"
        update(update_status_query)
        return redirect(url_for('admin.admin_view_food_request'))

    q = "SELECT * FROM food_request inner join donor using (donor_id)"
    res = select(q)
    data['view_f'] = res

    return render_template('admin_view_food_request.html', data=data)


@admin.route('/donor_details',methods=['post','get'])
def donor_details():
    data={}
    did=request.args['did']
    q="select * from donor where donor_id='%s'"%(did)
    res=select(q)
    data['view_d']=res
    
    return render_template('donor_details.html',data=data)


@admin.route('/add_menu', methods=['POST', 'GET'])
def add_menu():
    data = {}

    if 'submit' in request.form:
        menu = request.files['menu']
        filenames="static/"+str(uuid.uuid4())+ menu.filename
        menu_path = 'C:/Users/Asus/Documents/sh-clg-agedwell-seniorcare[1]/sh-clg-agedwell-seniorcare/'+filenames
        # path=""
        menu.save(menu_path)
        print("File saved to:", menu_path)

        
        donor_id = request.args.get('did')
        if donor_id:
            r = "SELECT * FROM donor WHERE donor_id='%s'" % (donor_id)
            res1 = select(r)  # Assuming select() is defined elsewhere
            print("ddddddddddd",res1)
            if res1:
                try:
                    query = "UPDATE food_request SET file_upload = '%s', status = 'uploaded' WHERE status = 'accepted'" % (filenames)
                    print("Executing query:", query)
                    res = update(query)  # Assuming update() is defined elsewhere
                    data['result'] = res

                    msg = MIMEText(f'Your menu has been succesfully added.')
                    msg['Subject'] = 'Menu Addedd'
                    msg['To'] = res1[0]['demail']
                    msg['From'] = 'hariharan0987pp@gmail.com'
                    with smtplib.SMTP('smtp.gmail.com', 587) as server:
                        server.starttls()
                        server.login('hariharan0987pp@gmail.com', 'rjcbcumvkpqynpep')
                        server.send_message(msg)
                    flash('A confirmation email has been sent to your email address.')
                except smtplib.SMTPException as e:	
                    print("Couldn't send email: " + str(e))
                    flash("Failed to send confirmation email. Please try again.")

    action = request.args.get('action')
    food_request_id = request.args.get('food_request_id')

    if action == 'delete' and food_request_id:
        q = f"DELETE FROM food_request WHERE food_request_id = '{food_request_id}'"
        delete(q)  # Assuming delete() is defined elsewhere
        return redirect(url_for('admin.add_menu'))

    q = "SELECT * FROM food_request"
    res = select(q)  # Assuming select() is defined elsewhere
    data['view_menu'] = res

    return render_template('add_menu.html', data=data)


@admin.route('/admin_add_article',methods=['post','get'])
def admin_add_article():
    data={}
    if 'submit' in request.form:
        menu = request.files['menu']
        filenames="static/"+str(uuid.uuid4())+ menu.filename
        menu_path = 'C:/Users/Asus/Documents/sh-clg-agedwell-seniorcare[1]/sh-clg-agedwell-seniorcare/'+filenames
        # path=""
        menu.save(menu_path)
        print("File saved to:", menu_path)
        q = "INSERT INTO article (article) VALUES ('%s')" % (filenames)
        insert(q)
        flash("uploaded successfully")

        return redirect(url_for("admin.admin_add_article"))
    action = request.args.get('action')
    article_id = request.args.get('article_id')

    if action == 'delete' and article_id:
        q = f"DELETE FROM article WHERE article_id = '{article_id}'"
        delete(q)
        return redirect(url_for('admin.admin_add_article'))
    
    q="select * from article"
    res=select(q)
    data['view_a']=res
    
    return render_template('admin_add_article.html',data=data)

@admin.route('/volunteer_requirement',methods=['post','get'])
def volunteer_requirement():
    data = {}
    if 'submit' in request.form:
        v_cat = request.form['v_cat']
        priority=request.form['priority']

        q = "INSERT INTO volu_req_category VALUES (null,'%s','%s')"%(v_cat,priority)
        insert(q)
        flash("Category added successfully") 
        return redirect(url_for('admin.volunteer_requirement'))
    
    if 'action' in request.args:
        action = request.args['action']
        cid = request.args['cid']
    else:
        action=None
    if action == 'delete':
        q ="DELETE FROM volu_req_category WHERE v_cat_id='%s'"%(cid)
        delete(q)
        flash("Deleted Succesfully")
        return redirect(url_for('admin.volunteer_requirement'))
    
    
    qview="select * from volu_req_category"
    data['view_c']=select(qview)
    return render_template ('volunteer_requirement.html',data=data)   

@admin.route('/donor_requirement', methods=['POST', 'GET'])
def donor_requirement():
    data = {}
    if 'submit' in request.form:
        d_cat = request.form['d_cat']
        priority=request.form['priority']
        q = "INSERT INTO donor_req_category VALUES (null,'%s','%s')"%(d_cat,priority)
        insert(q)
        flash("Category added successfully") 
        return redirect(url_for('admin.donor_requirement'))
    if 'action' in request.args:
        action = request.args['action']
        cid = request.args['cid']
    else:
        action=None
    if action == 'delete':
        q ="DELETE FROM donor_req_category WHERE d_cat_id='%s'"%(cid)
        delete(q)
        flash("Deleted Succesfully")
        return redirect(url_for('admin.donor_requirement'))  

    
    qview = "SELECT * FROM donor_req_category"
    data['dontview'] = select(qview)
    return render_template('donor_requirement.html', data=data)

@admin.route('/donor_d_requirement', methods=['post','get'])
def donor_d_requirement():
    data = {}
    if 'btn' in request.form:
        d_cat_id=request.args['d_cat_id']
        request_text= request.form['request_text']
        q = "INSERT INTO d_request VALUES (null,'%s','%s',curdate(), 'pending')" % (d_cat_id,request_text)
        insert(q)
        flash("Request added successfully")
        return redirect(url_for('admin.donor_requirement'))

    if 'action' in request.args:
        action = request.args['action']
        d_req_id = request.args['d_req_id']
    else:
        action = None

    if action == 'delete':
        q = "DELETE FROM d_request WHERE id='%s'" % (d_req_id)
        delete(q)
        flash("Deleted Successfully")
        return redirect(url_for('admin.donor_requirement'))

    qview = "SELECT * FROM d_request"
    data['d__requirement'] = select(qview)
    return render_template('donor_d_requirement.html', data=data)

@admin.route('/view_v_requirement', methods=['post','get'])
def view_v_requirement():
    data = {}
    if 'submit' in request.form:
        v_cat_id = request.args['v_cat_id']
        request_text= request.form['request_text']
        date=request.form['date']
        q = "INSERT INTO v_request VALUES (null,'%s','%s','%s','pending')" % (v_cat_id,request_text,date)
        insert(q)
        flash("Request added successfully")
        return redirect(url_for('admin.admin_home'))

    if 'action' in request.args:
        action = request.args['action']
        v_req_id = request.args['v_req_id']
       
    else:
        action = None
    if action == 'delete':
        q = "DELETE FROM v_request WHERE id='%s'" % (v_req_id)
        delete(q)
        flash("Deleted Successfully")
        return redirect(url_for('view_v_requirement'))

    qview = "SELECT * FROM v_request"
    data['v__requirement'] = select(qview)
    return render_template('view_v_requirement.html', data=data)


@admin.route('/view_appointment', methods=['POST', 'GET'])
def view_appointment():
    data = {}
    
    if 'submit' in request.form:
        app_title = request.form['app_title']
        return redirect(url_for('admin.adminhome'))

    action = request.args.get('action')
    book_appo_id = request.args.get('book_appo_id')
    
    if action == 'reject' and book_appo_id:
        q = f"DELETE FROM book_appo WHERE book_appo_id = '{book_appo_id}'"
        delete(q)
        return redirect(url_for('admin.view_appointment'))

    if action == "accept":
        book_appo_id=request.args['book_appo_id']
        update_status_query = "UPDATE book_appo SET booking_status = 'accept' WHERE book_appo_id = '%s'"%(book_appo_id)
        update(update_status_query)
        return redirect(url_for('admin.view_appointment'))

    if request.method == 'POST' and 'reject' in request.form:
        app_title = request.form['app_title']
        book_appo_id = request.form['book_appo_id']
        if book_appo_id:
            ups = "UPDATE book_appo SET app_title = '{app_title}' WHERE book_appo_id = '{book_appo_id}'"
            update(ups)
            return redirect(url_for('view_appointment'))

    q = "SELECT * FROM book_appo inner join volunteer using (volunteer_id)"
    res = select(q)
    data['view_a'] = res

    return render_template('view_appointment.html', data=data)






@admin.route('/donation_detail', methods=['POST', 'GET'])
def donation_detail():
    data = {}

    action = request.args.get('action')
    donation_item_id = request.args.get('donation_item_id')

    if action == 'reject' and donation_item_id:
        q = f"DELETE FROM donation_item WHERE donation_item_id = '{donation_item_id}'"
        delete(q)
        return redirect(url_for('admin.donation_detail'))

    if action == "accept" and donation_item_id:
        query = f"UPDATE donation_item SET status = 'admin accepted' WHERE donation_item_id = '{donation_item_id}'"
        update(query)
        return redirect(url_for('admin.donation_detail'))

    q = "SELECT * FROM donation_item inner join donor using(donor_id)"
    res = select(q)
    data['view_dd'] = res

    return render_template('donation_detail.html', data=data)




@admin.route('/add_class_video',methods=['post','get'])
def add_class_video():
    data={}
    
    q="select * from book_appo where booking_status <> 'pending'"
    res = select(q)
    data['appointments']=res
    
    q="select * from class_video"
    res = select(q)
    data['video_details']=res
    
    if 'submit' in request.form:
        appointment_id=request.form['appointment']
        
        q = "SELECT volunteer_id FROM `book_appo` WHERE book_appo_id = '%s'"%(appointment_id)
        res=select(q)
        volunteer_id=res[0]["volunteer_id"]
        
        title=request.form['title']
        video=request.files['video']
        class__path= r"C:\Users\Asus\Documents\sh-clg-agedwell-seniorcare[1]\sh-clg-agedwell-seniorcare\static"+str(uuid.uuid4())+ video.filename
        video.save(class__path)
        
        q="insert into class_video values (null,'%s','%s','%s','%s')"%(appointment_id, volunteer_id, title, class__path)
        insert(q)
        flash("Video Uploaded!")
        return redirect(url_for("admin.add_class_video"))
            
    return render_template('add_class_video.html',data=data)


@admin.route('/add_demo_video', methods=['post', 'get'])
def add_demo_video():
    data = {}
    q = "select * from demo_video"
    data['video'] = select(q)

    if 'submit' in request.form:
        video = request.files['video']
        menu__path = "static/"+str(uuid.uuid4())+video.filename
        video.save(menu__path)
        q = "insert into demo_video values (null, '%s')"%(menu__path)
        insert(q)

        flash("Video Uploaded!")
        return redirect(url_for("admin.add_demo_video"))
    return render_template('add_demo_video.html', data=data)

@admin.route('/delete_demo_video/<int:demo_video_id>', methods=['POST'])
def delete_demo_video(demo_video_id):
    if session.get("lid") is not None:
        q = f"DELETE FROM demo_video WHERE id={demo_video_id}"
        delete(q)  
        flash('Video deleted successfully.', 'success')
        return redirect(url_for('admin.add_demo_video'))
    else:
        return redirect(url_for('public.login'))


@admin.route('/view_volunteer',methods=['post','get'])
def view_volunteer():
    data={}
    
    q="select * from volunteer"
    res=select(q)
    data['view_v']=res
    
    return render_template('view_volunteer.html',data=data)   

from datetime import datetime

@admin.route('/track_volunteer', methods=['POST', 'GET'])
def track_volunteer():
    data = {}
    vid = request.args['vid']
    
    # Initialize data dictionary
    data['view_t'] = {
        'pickup_drop_times': [],
        'appointments': [],
        'total_working_hours': 0,
        'appointment_count': 0
    }
    
    # Query to get pickup and drop times along with volunteer details
    q = "SELECT vname, pickup_time, droptime, status FROM vol_pickup INNER JOIN volunteer USING (volunteer_id) WHERE volunteer_id='%s' AND status='delivered'" % (vid)
    pickup_drop_times = select(q)
    
    # Query to get appointment details
    w = "SELECT vname, app_title, bookingdate, booking_status FROM book_appo INNER JOIN volunteer USING(volunteer_id) WHERE volunteer_id='%s' AND booking_status='accept'" % (vid)
    appointments = select(w)
    
    # Calculate total working hours and number of appointments by month
    total_working_hours_by_month = {}
    appointment_count_by_month = {}
    
    for entry in pickup_drop_times:
        pickup_time = entry['pickup_time']
        drop_time = entry['droptime']
        
        # Convert string to datetime objects assuming the format is '%Y-%m-%d %H:%M:%S'
        pickup_time = datetime.strptime(pickup_time, '%Y-%m-%d %H:%M:%S')
        drop_time = datetime.strptime(drop_time, '%Y-%m-%d %H:%M:%S')
        
        # Calculate the difference in hours
        working_hours = (drop_time - pickup_time).total_seconds() / 3600.0  # Convert to hours
        
        # Get the month of the pickup time
        month = pickup_time.strftime('%Y-%m')
        
        if month not in total_working_hours_by_month:
            total_working_hours_by_month[month] = 0
        total_working_hours_by_month[month] += working_hours

    for appointment in appointments:
        booking_date = appointment['bookingdate']
        
        # Convert string to datetime object assuming the format is '%Y-%m-%d'
        booking_date = datetime.strptime(booking_date, '%Y-%m-%d')
        
        # Get the month of the booking date
        month = booking_date.strftime('%Y-%m')
        
        if month not in appointment_count_by_month:
            appointment_count_by_month[month] = 0
        appointment_count_by_month[month] += 1
    
    # Prepare data for insertion/update
    for month, total_working_hours in total_working_hours_by_month.items():
        appointment_count = appointment_count_by_month.get(month, 0)
        
        # Check if there's already a record for the current month
        check_query = "SELECT * FROM track WHERE volunteer_id='%s' AND DATE_FORMAT(month, '%%Y-%%m')='%s'" % (vid, month)
        existing_record = select(check_query)
        
        if existing_record:
            # Update the existing record
            update_query = "UPDATE track SET total_working_hours='%s', appointment_count='%s' WHERE volunteer_id='%s' AND DATE_FORMAT(month, '%%Y-%%m')='%s'" % (total_working_hours, appointment_count, vid, month)
            update(update_query)
        else:
            # Insert a new record
            insert_query = "INSERT INTO track (volunteer_id, total_working_hours, appointment_count, month,status) VALUES ('%s', '%s', '%s', '%s-01','pending')" % (vid, total_working_hours, appointment_count, month)
            insert(insert_query)
    
    # Fetch monthly data for display
    monthly_data_query = "SELECT DATE_FORMAT(month, '%%Y-%%m') as month, total_working_hours, appointment_count FROM track WHERE volunteer_id='%s' ORDER BY month DESC" % (vid)
    monthly_data = select(monthly_data_query)
    
    # Populate data dictionary with fetched data
    data['view_t']['pickup_drop_times'] = pickup_drop_times
    data['view_t']['appointments'] = appointments
    data['view_t']['total_working_hours'] = sum(total_working_hours_by_month.values())
    data['view_t']['appointment_count'] = sum(appointment_count_by_month.values())
    data['monthly_data'] = monthly_data
    
    return render_template('track_volunteer.html', data=data)






@admin.route('/chat_volunteer', methods=['get', 'post'])
def chat_volunteer():
  
    data = {}
    data['uid'] = session['lid']
    cid = request.args['vid']

    qry = "SELECT *,volunteer.vname AS username FROM volunteer WHERE volunteer_id = '%s'" % (cid)
    result = select(qry)
    data['name'] = result

    if 'submit' in request.form:
        message = request.form['msg']
        # Ensure this parameter is passed in the request
        q2 = """
        INSERT INTO chat (sender_id, receiver_id, sender_type, receiver_type, message, date,is_read)
        VALUES ('%s', '%s', 'admin', 'volunteer', '%s', CURDATE(),'0')
        """ % (session['lid'], cid,message)
        insert(q2)
        return redirect(url_for('admin.chat_volunteer', vid=cid))

    q = """
    SELECT * 
    FROM chat 
    WHERE ((sender_id = '%s' AND receiver_id = '%s') OR (sender_id = '%s' AND receiver_id = '%s'))
    """ % (session['lid'], cid, cid, session['lid'])
    res = select(q)
    data['msg'] = res
    return render_template('chat_volunteer.html', data=data)


@admin.route('/chat_donor', methods=['get', 'post'])
def chat_donor():
  
    data = {}
    data['uid'] = session['lid']
    cid = request.args['vid']

    qry = "SELECT *,donor.dname AS username FROM donor WHERE donor_id = '%s'" % (cid)
    result = select(qry)
    data['name'] = result

    if 'submit' in request.form:
        message = request.form['msg']
        # Ensure this parameter is passed in the request
        q2 = """
        INSERT INTO chat (sender_id, receiver_id, sender_type, receiver_type, message, date)
        VALUES ('%s', '%s', 'admin', 'volunteer', '%s', CURDATE())
        """ % (session['lid'], cid,message)
        insert(q2)
        return redirect(url_for('admin.chat_donor', vid=cid))

    q = """
    SELECT * 
    FROM chat 
    WHERE ((sender_id = '%s' AND receiver_id = '%s') OR (sender_id = '%s' AND receiver_id = '%s'))
    """ % (session['lid'], cid, cid, session['lid'])
    res = select(q)
    data['msg'] = res
    return render_template('chat_donor.html', data=data)   

	
from datetime import datetime

@admin.route('/reward', methods=['POST', 'GET'])
def reward():
    data = {}
    q = "SELECT volunteer_id, vname, DATE_FORMAT(MONTH, '%Y-%m') AS month, total_working_hours, appointment_count,track_id,status FROM volunteer INNER JOIN track USING(volunteer_id)"
    res = select(q)
    data['reward'] = res

    # Find the highest volunteer for each month
    monthly_data = {}
    for entry in res:
        month = entry['month']
        if month not in monthly_data:
            monthly_data[month] = entry
        else:
            if entry['total_working_hours'] > monthly_data[month]['total_working_hours'] or \
               (entry['total_working_hours'] == monthly_data[month]['total_working_hours'] and entry['appointment_count'] > monthly_data[month]['appointment_count']):
                monthly_data[month] = entry

    # Mark the best volunteer for each month
    for entry in res:
        month = entry['month']
        if entry == monthly_data[month]:
            entry['is_best_volunteer'] = True
        else:
            entry['is_best_volunteer'] = False

    data['reward'] = res

    if 'action' in request.args:
        action = request.args['action']
        vid = request.args['vid']
        month = request.args['month']
        tid = request.args['tid']
    else:
        action = None

    if action == 'reward':
        i = "INSERT INTO reward VALUES (NULL, '%s', 'Volunteer of the Month', '%s')" % (vid, month)
        insert(i)
        u = "UPDATE track SET status='Best Volunteer' WHERE track_id='%s'" % (tid)
        update(u)
        flash("Reward Sended Successfully")
        return redirect(url_for("admin.admin_home"))
    
    return render_template('reward.html', data=data)

@admin.route('/admin_senditem_reply',methods=['get','post'])
def admin_senditem_reply():
   
    if 'submit' in request.form:
        reply=request.form['reply']
        reply_image=request.files['reply_image']
        path="static/image"+str(uuid.uuid4())+reply_image.filename
        reply_image.save(path)
        donation_item_id=request.args['donation_item_id']
        i="update donation_item set reply='%s', file_upload='%s' where donation_item_id='%s'"%(reply,path,donation_item_id)
        insert(i)
        flash("Reply Sended Successfully")
        return redirect(url_for('admin.admin_home'))
    return render_template('admin_senditem_reply.html')


@admin.route('/admin_view_donationamount',methods=['get','post'])
def admin_view_donationamount():
    data={}
    u="select * from donation_payment inner join donor using(donor_id)"
    data['view']=select(u)
    return render_template('admin_view_donationamount.html',data=data)



@admin.route('/admin_sendpaymeant_reply',methods=['get','post'])
def admin_sendpaymeant_reply():
   
    if 'submit' in request.form:
        reply=request.form['reply']
        reply_image=request.files['reply_image']
        path="static/image"+str(uuid.uuid4())+reply_image.filename
        reply_image.save(path)
        donation_payment_id=request.args['donation_payment_id']
        i="update donation_payment set reply='%s', file_upload='%s' where donation_payment_id='%s'"%(reply,path,donation_payment_id)
        insert(i)
        flash("Reply Sended Successfully")
        return redirect(url_for('admin.admin_home'))

    return render_template('admin_sendpaymeant_reply.html')







