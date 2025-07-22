import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyDonationsScreen extends StatefulWidget {
  static const routeName = "/MyDonations";

  const MyDonationsScreen({Key? key}) : super(key: key);

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  List<Map<String, dynamic>> messageData = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _deleteItem(String book_id, int index, BuildContext context) async {
    try {
      final sh = await SharedPreferences.getInstance();
      String url = sh.getString("url") ?? "";
      String lid = sh.getString("lid") ?? "";

      var response = await http.post(
        Uri.parse(url + "/api/delete_appo"),
        body: {'lid': lid, 'book_id': book_id},
      );

      var jsonData = json.decode(response.body);
      String status = jsonData['status'].toString();

      if (status == "true") {
        setState(() {
          messageData.removeAt(index);
        });
        print('Appointment deleted successfully!');
      } else {
        print('Failed to delete appointment: ${jsonData['message']}');
      }
    } catch (e) {
      print('Error deleting appointment: $e');
    }
  }

  void _showDeleteConfirmationPopup(String book_id, int index, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteItem(book_id, index, context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadMessages() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String categoryUrl = ip + "/api/view_booked_apo";

      var data = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      var jsonData = json.decode(data.body);
      String status = jsonData['status'].toString();

      if (status == "true") {
        setState(() {
          messageData = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      } else {
        // Handle error status if needed
      }
    } catch (e) {
      print("Error: $e");
      // Handle any errors that occur during the HTTP request.
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      builder: (context, child) => Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    iconSize: 14.w,
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    "My Appointments",
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    width: 50.w,
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 20.h,
                ),
                child: Image(
                  image: const AssetImage("assets/main_assets/vol.jpg"),
                  width: 385.w,
                  height: 194.h,
                ),
              ),
              SizedBox(
                height: 50.h,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0EEEF),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              messageData.length.toString(),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              "Total Appointments",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 14.h,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Text(
                                  "Appointment For",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "Date",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "Status",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 12.h,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: messageData.length,
                            itemBuilder: (context, index) {
                              final book_id =
                              messageData[index]['book_appo_id'].toString();
                              return MyAppointmentInfo(
                                index: index,
                                title: messageData[index]['app_title'] ?? "Not Available",
                                date: messageData[index]['bookingdate'] ?? "Not Available",
                                status: messageData[index]['booking_status'] ?? "Not Available",
                                onDelete: () => _showDeleteConfirmationPopup(book_id, index, context),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyAppointmentInfo extends StatelessWidget {
  final int index;
  final String title;
  final String date;
  final String status;
  final VoidCallback onDelete;

  const MyAppointmentInfo({
    Key? key,
    required this.index,
    required this.title,
    required this.date,
    required this.status,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      padding: EdgeInsets.fromLTRB(9.w, 23.h, 9.w, 0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w400),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  date,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 12.h,
                      width: 12.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF419485),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.h,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE0EEEF),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: GestureDetector(
              onTap: () {
                //code for showing receipt
                //to be implemented later
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Cancel  Appointment ",
                    style: TextStyle(
                      color: const Color(0xFFF1002B),
                      fontSize: 18.sp,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete,
                      color: Color(0xFFFC0C2F),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: const Color(0xFFD9D9D9),
            thickness: 5.h,
          )
        ],
      ),
    );
  }
}
