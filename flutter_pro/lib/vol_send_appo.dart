import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pro/vol_home.dart';
import 'package:flutter_pro/vol_view_appo.dart';
import 'package:flutter_pro/vol_view_req_cat.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SendAppointment extends StatefulWidget {
  static const String routeName = '/DonationPage';
  const SendAppointment({Key? key}) : super(key: key);

  @override
  State<SendAppointment> createState() => _SendAppointmentState();
}

class _SendAppointmentState extends State<SendAppointment> {
  bool isChecked = false;
  DateTime? selectedDate;
  TextEditingController titleController = TextEditingController();
  List<Map<String, dynamic>> messageData = [];

  void fetchbooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String lid = prefs.getString("lid").toString();
    String url = ip + "/api/view_booked_apo";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'lid': lid},
      );
      var jsonData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          messageData = List<Map<String, dynamic>>.from(jsonData['data']);
        });
      } else {
        print('Failed to fetch complaints. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching complaints: $error');
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    List<DateTime> bookedDates = await _fetchBookedDates();

    // Set initialDate based on selectedDate or default to tomorrow if selectedDate is null
    DateTime initialDate = selectedDate ?? DateTime.now().add(Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 1),
      selectableDayPredicate: (DateTime date) {
        // Ensure the picked date is not in the list of booked dates
        return !bookedDates.contains(date);
      },
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }


  Future<List<DateTime>> _fetchBookedDates() async {
    final SharedPreferences sh = await SharedPreferences.getInstance();
    final String? url = sh.getString("url");

    if (url != null) {
      final response = await http.get(Uri.parse('$url/api/send_appo'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final status = jsonData['status'].toString();

        if (status == "true") {
          List bookedDates = jsonData['booked_dates'];
          return bookedDates.map((dateString) {
            try {
              return DateTime.parse(dateString);
            } catch (e) {
              List<String> parts = dateString.split('-');
              if (parts.length == 3) {
                int year = int.parse(parts[0]);
                int month = int.parse(parts[1]);
                int day = int.parse(parts[2]);
                return DateTime(year, month, day);
              } else {
                throw FormatException("Invalid date format");
              }
            }
          }).toList();
        } else {
          print("Error fetching booked dates");
          return [];
        }
      } else {
        print("HTTP Error ${response.statusCode}");
        return [];
      }
    } else {
      print("Error: SharedPreferences data not found");
      return [];
    }
  }

  Future<void> _bookAppointment() async {
    final SharedPreferences sh = await SharedPreferences.getInstance();
    final String? lid = sh.getString("lid");
    final String? url = sh.getString("url");

    if (lid != null && url != null) {
      String formattedDate = selectedDate != null
          ? "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}"
          : '';

      final response = await http.post(
        Uri.parse('$url/api/send_appo'),
        body: {
          'login_id': lid,
          'title': titleController.text,
          'selected_date': formattedDate,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final status = jsonData['status'].toString();

        if (status == "true") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePageIndividual()),
          );
        } else {
          print("Error: $status");
        }
      } else {
        print("HTTP Error ${response.statusCode}");
      }
    } else {
      print("Error: SharedPreferences data not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            "Appointment",
            style: TextStyle(
              color: Colors.black,
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 250.sp,
                    width: double.infinity,
                    child: const Image(
                      filterQuality: FilterQuality.high,
                      image: AssetImage(
                        'assets/startup_assets/individual_assets/donation.png',
                      ),
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 176, 229, 233),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Enter the Title",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        TextFormField(
                          controller: titleController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 190, 190, 190),
                            hintText: 'Title',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15.h, horizontal: 20.w),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 190, 190, 190),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              selectedDate == null
                                  ? 'Select Date'
                                  : 'Selected Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  SizedBox(
                    height: 50.h,
                    width: 200.w,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        backgroundColor: const Color.fromARGB(255, 190, 190, 190),
                      ),
                      onPressed: _bookAppointment,
                      child: Text(
                        "Book",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Stack(
          children: [
            // First button
            Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyDonationsScreen(),
                    ),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 190, 190, 190),
                label: Text(
                  "Appointments",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: Icon(
                  Icons.calendar_today,
                  size: 20.w,
                ),
              ),
            ),
            // Second button
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                onPressed: () {
                  // Add another functionality here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => vol_view_req_cat(), // Replace with your second screen
                    ),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 190, 190, 190),
                label: Text(
                  "Requirements",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: Icon(
                  Icons.alternate_email, // Change to an icon that fits your action
                  size: 20.w,
                ),
              ),
            ),
          ],
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}
