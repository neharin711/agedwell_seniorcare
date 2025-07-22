from flask import *

from database import *
import uuid


api=Blueprint('api',__name__)
@api.route('/reset_notifications', methods=['POST'])
def reset_notifications():
    login_id = request.form['lid']
    
    # Assuming you have a mechanism to mark notifications as read.
    # This could be an update query or another mechanism.

    # Example:
    # chat_update_query = "UPDATE chat SET is_read=1 WHERE receiver_id='%s'" % (login_id)
    # donation_update_query = "UPDATE donation_item SET is_read=1 WHERE status='admin accepted'"

    # Mark notifications as read
    # update(chat_update_query)
    # update(donation_update_query)

    # Return the updated count (which will be zero after reset)
    return jsonify(status="true", count=0)
@api.route('/mark_notifications_as_read', methods=['POST'])
def mark_notifications_as_read():
    login_id = request.form['lid']
    
    # Example update queries to mark notifications as read
    chat_update_query = "UPDATE chat SET is_read=1 WHERE receiver_id='%s'" % (login_id)
    donation_update_query = "UPDATE donation_item SET is_read=1 WHERE status='admin accepted'"

    update(chat_update_query)
    update(donation_update_query)

    return jsonify(status="true")
@api.route('/unread_requests', methods=['POST'])
def unread_requests():
    login_id = request.form['lid']
    
    request_query = "SELECT * FROM donation_item WHERE status='admin accepted' AND is_read=0"
    request_res = select(request_query)

    total_unread_requests = len(request_res)

    return jsonify(status="true", count=total_unread_requests, request_data=request_res)

@api.route('/unread_notifications', methods=['POST'])
def unread_notifications():
    login_id = request.form['lid']

    chat_query = "SELECT * FROM chat WHERE receiver_id='%s' AND is_read=0" % (login_id)
    chat_res = select(chat_query)
    
    

    total_unread_notifications = len(chat_res)

    return jsonify(status="true", count=total_unread_notifications, chat_data=chat_res, donation_data='0')

# @api.route('/notification', methods=['POST'])
# def notification():
#     login_id = request.form['lid']
    

#     chat_query = "select * from chat where receiver_id='%s'" % (login_id)
#     chat_res = select(chat_query)
#     #print("ccccccccccccc",chat_res)
   
#     donation_query = "select * from donation_item where status='admin accepted'"
#     donation_res = select(donation_query)
#     #print("dddddddddd",donation_res)

#     total_notifications = len(chat_res) + len(donation_res) if chat_res or donation_res else 0
    
#     if total_notifications > 0:
#         return jsonify(status="true", count=total_notifications)
#     else:
#         return jsonify(status="false", count=0)



@api.route('/login', methods=['post'])
def login():
    Uname = request.form['username1']
    Paswd = request.form['password']

    q = "select * from login where username='%s' and password='%s'" % (Uname, Paswd)
    res = select(q)

    if res:
        user = res[0]
        login_id = user['login_id']
        utype = user['usertype'].strip().lower()

        if utype == 'donor':
            query2 = "SELECT * FROM donor WHERE login_id ='%s'" % login_id
            res2 = select(query2)

            if res2:
                donor = res2[0]
                return jsonify(
                    status="true", 
                    lid=user['login_id'], 
                    type=user['usertype'], 
                    phone=donor['dphone'], 
                    img=donor['dp_image']
                )
            else:
                return jsonify(status="false", message="Donor details not found")
        elif utype == 'volunteer':
            q2 = "select * from volunteer where login_id='%s'" % login_id
            res4 = select(q2)

            if res4:
                volunteer = res4[0]
                return jsonify(
                    status="true",
                    lid=user['login_id'],
                    type=user['usertype'],
                    img=volunteer['p_image']
                )
            else:
                return jsonify(status="false", message="Volunteer details not found")
        else:
            return jsonify(status="false", message="Unknown user type")
    else:
        return jsonify(status="false", message="Invalid username or password")

@api.route('/view_vol',methods=['get','post'])
def view_vol():
	data={}
	login_id=request.form['lid']
	r="select * from volunteer inner join login using(login_id) where login_id='%s'"%(login_id)
	res=select(r)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/vol_update',methods=['get','post'])
def vol_update():
	data = {}
	name=request.form['vname']
	email=request.form['email']
	phone=request.form['phone']
	occupation=request.form['occupation']
	city=request.form['city']
	gender=request.form['gender']
	dob=request.form['dateofbirth']
	uname=request.form['username']
	passw=request.form['password']
	image1=request.files['file_upload']
	path1='static/image/'+str(uuid.uuid4())+image1.filename
	image1.save(path1)
	image2=request.files['p_image']
	path2='static/image/'+str(uuid.uuid4())+image2.filename
	image2.save(path2)
	login_id=request.form['lid']
	q= "update login set username='%s',password='%s' where login_id='%s'"%(uname,passw,login_id)
	lid = update(q)
	qr="update `volunteer` set vname='%s',email='%s',phone='%s',occupation='%s',gender='%s',dateofbirth='%s',city='%s',file_upload='%s',p_image='%s' where login_id='%s'"%(name,email,phone,occupation,gender,dob,city,path1,path2,login_id)
	res=update(qr)
	if res:
		return jsonify(status="true")
	else:
		return jsonify(status="false")

@api.route('/vol_register',methods=['get','post'])
def vol_register():
	data = {}
	name=request.form['name']
	email=request.form['email']
	phone=request.form['phone']
	occupation=request.form['occupation']
	city=request.form['city']
	gender=request.form['gender']
	dob=request.form['dob']
	uname=request.form['username']
	passw=request.form['password']
	image1=request.files['document']
	path1='static/image/'+str(uuid.uuid4())+image1.filename
	image1.save(path1)
	image2=request.files['profile_image']
	path2='static/image/'+str(uuid.uuid4())+image2.filename
	image2.save(path2)
	q= "INSERT INTO `login` VALUES(NULL,'%s','%s','volunteer')"%(uname,passw)
	lid = insert(q)
	qr="INSERT INTO `volunteer` VALUES(NULL,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')"%(lid,name,email,phone,occupation,gender,dob,city,path1,path2)
	res=insert(qr)
	if res:
		return jsonify(status="true")
	else:
		return jsonify(status="false")
@api.route('/view_chat_list',methods=['get','post'])
def view_chat_list():

	data = {}
	
	login_id=request.form['lid']
	
	r="select * from chat inner join volunteer on chat.sender_id=volunteer.login_id or chat.receiver_id=volunteer.login_id where login_id='%s'"%(login_id)
	res=select(r)
	#print("TTtttttttttttttttttt",res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/chat_with_admin',methods=['get','post'])
def chat_with_admin():

	data = {}
	
	login_id=request.form['lid']
	message=request.form['message']
	r="insert into chat VALUES(null,'%s','1','%s',curdate(),'volunteer','admin','0')"%(login_id,message)
	res=insert(r)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/send_appo', methods=['get', 'post'])
def send_appo():
    if request.method == 'POST':
        data = {}
        login_id = request.form['login_id']
        title = request.form['title']
        date = request.form['selected_date']
        r = "insert into book_appo VALUES(null,'%s','%s','%s','pending')" % (login_id, title, date)
        res = insert(r)
        if res:
            return jsonify(status="true", data=res)
        else:
            return jsonify(status="false")

    elif request.method == 'GET':
        r = "select bookingdate from book_appo where booking_status='accept'"
        booked_dates = select(r)
        booked_dates_list = [row['bookingdate'] for row in booked_dates]
        return jsonify(status="true", booked_dates=booked_dates_list)
@api.route('/view_booked_apo',methods=['get','post'])
def view_booked_apo():

	data = {}
	
	login_id=request.form['lid']
	
	r="select * from book_appo where volunteer_id='%s' order by book_appo_id desc"%(login_id)
	res=select(r)
	#print("TTtttttttttttttttttt",res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")

@api.route('/delete_appo',methods=['get','post'])
def delete_appo():

	data = {}
	
	login_id=request.form['lid']
	book_id=request.form['book_id']
	
	r="delete from book_appo where book_appo_id='%s'"%(book_id)
	res=delete(r)
	#print("TTtttttttttttttttttt",res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/view_review',methods=['get','post'])
def view_review():

	data = {}
	
	
	
	r="select * from review inner join volunteer on volunteer.login_id=review.volunteer_id"
	res=select(r)
	
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/send_review',methods=['get','post'])
def send_review():

	data = {}
	
	lid=request.form['login_id']
	rate=request.form['rate']
	review=request.form['review']
	
	r="insert into review VALUES(null,'%s','%s','%s',curdate())"%(lid,review,rate)
	res=insert(r)
	
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/view_avg_review', methods=['GET', 'POST'])
def view_avg_review():
    data = {}
    try:
        login_id = request.form['login_id']
        
        # Query to fetch average rate, rating count, and star counts for each rating
        query = """
            SELECT 
                AVG(rate) as average_rate, 
                COUNT(rate) as rating_count, 
                SUM(CASE WHEN rate = 5 THEN 1 ELSE 0 END) as 5_star_count, 
                SUM(CASE WHEN rate = 4 THEN 1 ELSE 0 END) as 4_star_count, 
                SUM(CASE WHEN rate = 3 THEN 1 ELSE 0 END) as 3_star_count, 
                SUM(CASE WHEN rate = 2 THEN 1 ELSE 0 END) as 2_star_count, 
                SUM(CASE WHEN rate = 1 THEN 1 ELSE 0 END) as 1_star_count 
            FROM review 
            
        """
        
        result = select(query)

        if result:
            data['average_rate'] = result[0]['average_rate'] if result[0]['average_rate'] is not None else 0.0
            data['rating_count'] = result[0]['rating_count']
            data['5_star_count'] = result[0]['5_star_count']
            data['4_star_count'] = result[0]['4_star_count']
            data['3_star_count'] = result[0]['3_star_count']
            data['2_star_count'] = result[0]['2_star_count']
            data['1_star_count'] = result[0]['1_star_count']
        else:
            data['average_rate'] = 0.0
            data['rating_count'] = 0
            data['5_star_count'] = 0
            data['4_star_count'] = 0
            data['3_star_count'] = 0
            data['2_star_count'] = 0
            data['1_star_count'] = 0

        return jsonify({'data': data, 'status': 'true'}), 200

    except Exception as e:
        #print("Error occurred:", e)
        return jsonify({'error': 'An error occurred'}), 500
@api.route('/view_class_video',methods=['get','post'])
def view_class_video():
	data = {}
	e="SELECT * FROM `class_video` INNER JOIN `volunteer` USING(`volunteer_id`) INNER JOIN `book_appo` USING(`book_appo_id`)"
	res=select(e)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/vol_view_request',methods=['get','post'])
def vol_view_request():
	data = {}
	e="SELECT * FROM `donation_item` INNER JOIN `donor` USING(`donor_id`) where status='admin accepted'"
	res=select(e)
	#print(res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
# @api.route('/vol_view_request',methods=['get','post'])
# def vol_view_request():
# 	data = {}
# 	e="SELECT * FROM `donation_item` INNER JOIN `donor` USING(`donor_id`) where status='pending'"
# 	res=select(e)
# 	#print(res)
# 	if res:
# 		return jsonify(status="true",data=res)
# 	else:
# 		return jsonify(status="false")
@api.route('/vol_view_pickup',methods=['get','post'])
def vol_view_pickup():
	data = {}
	e="SELECT * FROM `donation_item` INNER JOIN `donor` USING(`donor_id`)where status='Accept'"
	res=select(e)
	#print(res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/vol_view_delivered',methods=['get','post'])
def vol_view_delivered():
	data = {}
	e="SELECT * FROM `donation_item` INNER JOIN `donor` USING(`donor_id`) inner join vol_pickup USING(donation_item_id) where donation_item.status='Pickup' or donation_item.status='delivered'"
	res=select(e)
	#print(res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/vol_updatestatus',methods=['get','post'])
def vol_updatestatus():
	data = {}
	donation_item_id=request.form['donation_item_id']
	login_id=request.form['lid']
	e="update donation_item set status='Accept' where donation_item_id='%s'"%(donation_item_id)
	res=update(e)
	i="insert into vol_pickup VALUES(null,'%s',(select volunteer_id from volunteer where login_id='%s'),now(),'pending','Accept')"%(donation_item_id,login_id)
	res=insert(i)
	#print(res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/vol_updatestatus_pickup',methods=['get','post'])
def vol_updatestatus_pickup():
	data = {}
	donation_item_id=request.form['donation_item_id']
	login_id=request.form['lid']
	e="update donation_item set status='Pickup' where donation_item_id='%s'"%(donation_item_id)
	res=update(e)
	i="update vol_pickup set status='Pickup' where donation_item_id='%s'"%(donation_item_id)

	res=update(i)
	#print(res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/vol_updatestatus_delivered',methods=['get','post'])
def vol_updatestatus_delivered():
	data = {}
	donation_item_id=request.form['donation_item_id']
	login_id=request.form['lid']
	e="update donation_item set status='delivered' where donation_item_id='%s'"%(donation_item_id)
	res=update(e)
	i="update vol_pickup set status='delivered',droptime=now() where donation_item_id='%s'"%(donation_item_id)

	res=update(i)
	
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/article',methods=['get','post'])
def article():
	data = {}
	e="SELECT * FROM article"
	res=select(e)
	
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/demo_video',methods=['get','post'])
def demo_video():
	data = {}
	e="SELECT * FROM demo_video"
	res=select(e)
	
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/vol_view_reward',methods=['post'])
def vol_view_reward():
	data={}
	r="select * from reward inner join track using(track_id) inner join volunteer on reward.volunteer_id=volunteer.volunteer_id"
	res=select(r)
	#print("KKKKKKKKKKKKKKK",res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
# =================donor===========================


@api.route('/donorregister',methods=['get','post'])
def donorregister():
	data = {}
	name=request.form['name']
	email=request.form['email']
	phone=request.form['phone']
	occupation=request.form['occupation']
	city=request.form['city']
	gender=request.form['gender']
	dob=request.form['dob']
	uname=request.form['username']
	passw=request.form['password']
	image1=request.files['document']
	path1='static/image/'+str(uuid.uuid4())+image1.filename
	image1.save(path1)
	image2=request.files['profile_image']
	path2='static/image/'+str(uuid.uuid4())+image2.filename
	image2.save(path2)
	q= "INSERT INTO `login` VALUES(NULL,'%s','%s','donor')"%(uname,passw)
	lid = insert(q)
	qr="INSERT INTO `donor` VALUES(NULL,'%s','%s','%s','%s','%s','%s','%s','%s','%s','%s')"%(lid,name,email,phone,occupation,gender,dob,city,path1,path2)
	res=insert(qr)
	if res:
		return jsonify(status="true")
	else:
		return jsonify(status="false")
@api.route('/view_donor_chat_list',methods=['get','post'])
def view_donor_chat_list():

	data = {}
	
	login_id=request.form['lid']
	
	r="select * from chat inner join donor on chat.sender_id=donor.login_id or chat.receiver_id=donor.login_id where login_id='%s'"%(login_id)
	res=select(r)
	#print("TTtttttttttttttttttt",res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/chat_donor_with_admin',methods=['get','post'])
def chat_donor_with_admin():

	data = {}
	
	login_id=request.form['lid']
	message=request.form['message']
	r="insert into chat VALUES(null,'%s','1','%s',curdate(),'donor','admin','null')"%(login_id,message)
	res=insert(r)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/donation_item',methods=['get','post'])
def donation_item():
	login_id=request.form['lid']
	item=request.form['item']
	qty=request.form['qty']
	type=request.form['type']
	date=request.form['date']
	time=request.form['time']
	pickup=request.form['pickup']
	pickup_option=request.form['pickup_option']
	i="insert into donation_item VALUES(null,(select donor_id from donor where login_id='%s'),'%s','%s','%s','%s','%s','pending','pending','pending','%s','%s','0')"%(login_id,item,qty,type,date,time,pickup,pickup_option)
	res=insert(i)
	if res:
		return jsonify(status="true")
	else:
		return jsonify(status="false")

@api.route('/view_donor',methods=['get','post'])
def view_donor():
	data = {}
	login_id=request.form['lid']
	e="SELECT * FROM donor where donor_id=(select donor_id from donor where login_id='%s')"%(login_id)
	res=select(e)
	
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/view_donation_item',methods=['get','post'])
def view_donation_item():
	data = {}
	login_id=request.form['lid']
	e="SELECT * FROM donation_item  inner join donor using(donor_id) where donor_id=(select donor_id from donor where login_id='%s')"%(login_id)
	res=select(e)
	
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/donation_payment',methods=['get','post'])
def donation_payment():
	login_id=request.form['lid']
	amount=request.form['amount']
	i="insert into donation_payment VALUES(null,(select donor_id from donor where login_id='%s'),'%s',curdate(),'pending','pending')"%(login_id,amount)
	res=insert(i)	
	if res:
		return jsonify(status="true")
	else:
		return jsonify(status="false")

@api.route('/view_donation_payment',methods=['get','post'])
def view_donation_payment():
	data = {}
	login_id=request.form['lid']
	e="SELECT * FROM donation_payment where donor_id=(select donor_id from donor where login_id='%s')"%(login_id)
	res=select(e)
	#print(res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/check_the_food_request',methods=['get','post'])
def check_the_food_request():

	login_id = request.form['lid']
	day = request.form['day']
	date = request.form['date']
	s = "SELECT * FROM food_request WHERE day='%s' AND date='%s'" % (day, date)
	r = select(s)
	print("iiiiiiiiiiii",s)
	if r:
		print("kkkkkkkkk")
		return jsonify(status="already_booked",data=r)
	else:
		return jsonify(status="false")

@api.route('/food_donation', methods=['get', 'post'])
def food_donation():
    login_id = request.form['lid']
    day = request.form['day']
    date = request.form['date']
    f = "INSERT INTO food_request VALUES(NULL, (SELECT donor_id FROM donor WHERE login_id='%s'), 'pending', '%s', '%s', 'pending')" % (login_id, day, date)
    res = insert(f)
    
    if res:
        return jsonify(status="true", data=res)
    else:
        return jsonify(status="false")

@api.route('/view_food_donation',methods=['get','post'])
def view_food_donation():
	login_id=request.form['lid']
	e="SELECT * FROM food_request where donor_id=(select donor_id from donor where login_id='%s')"%(login_id)
	res=select(e)
	#print(res)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/confirm_food',methods=['get','post'])
def confirm_food():
	food_request_id=request.form['food_request_id']
	y="update food_request set status='confirm' where food_request_id='%s'"%(food_request_id)
	res=update(y)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/view_volunteer',methods=['get','post'])
def view_volunteer():
	donation_item_id=request.form['donation_item_id']
	y="select * from vol_pickup inner join volunteer using(volunteer_id) where vol_pickup.donation_item_id='%s'"%(donation_item_id)
	res=select(y)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/viewreview',methods=['get','post'])
def viewreview():
	data={}
	d="select * from review inner join volunteer using(volunteer_id)"
	res=select(d)
	
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")

@api.route('/userviewreply', methods=['GET', 'POST'])
def userviewreply():
    data = {}
    d1 = "select * from donation_item inner join donor using(donor_id) where reply!='pending'"
    res1 = select(d1)
    d2 = "select * from donation_payment inner join donor using(donor_id) where reply!='pending'"
    res2 = select(d2)
    
    combined_data = {
        "donation_items": res1 if res1 else [],
        "donation_payments": res2 if res2 else []
    }
    #print(combined_data)
    if res1 or res2:
        return jsonify(status="true", data=combined_data)
    else:
        return jsonify(status="false")
@api.route('/view_donor_update',methods=['get','post'])
def view_donor_update():
	data={}
	login_id=request.form['lid']
	r="select * from donor inner join login using(login_id) where login_id='%s'"%(login_id)
	res=select(r)
	if res:
		return jsonify(status="true",data=res)
	else:
		return jsonify(status="false")
@api.route('/donor_update',methods=['get','post'])
def donor_update():
	data = {}
	name=request.form['vname']
	email=request.form['email']
	phone=request.form['phone']
	occupation=request.form['occupation']
	city=request.form['city']
	gender=request.form['gender']
	dob=request.form['dateofbirth']
	uname=request.form['username']
	passw=request.form['password']
	image1=request.files['file_upload']
	path1='static/image/'+str(uuid.uuid4())+image1.filename
	image1.save(path1)
	image2=request.files['p_image']
	path2='static/image/'+str(uuid.uuid4())+image2.filename
	image2.save(path2)
	login_id=request.form['lid']
	q= "update login set username='%s',password='%s' where login_id='%s'"%(uname,passw,login_id)
	lid = update(q)
	qr="update `donor` set dname='%s',demail='%s',dphone='%s',doccupation='%s',dgender='%s',ddateofbirth='%s',dcity='%s',dfile_upload='%s',dp_image='%s' where login_id='%s'"%(name,email,phone,occupation,gender,dob,city,path1,path2,login_id)
	res=update(qr)
	if res:
		return jsonify(status="true")
	else:
		return jsonify(status="false")