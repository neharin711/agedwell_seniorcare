import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class do_viewfoodrequest extends StatefulWidget {
  const do_viewfoodrequest({Key? key}) : super(key: key);

  @override
  _DoViewFoodRequestState createState() => _DoViewFoodRequestState();
}

class _DoViewFoodRequestState extends State<do_viewfoodrequest> {
  List<Map<String, dynamic>> messageData = [];

  @override
  void initState() {
    super.initState();
    fetchBooking();
  }

  Future<void> fetchBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String lid = prefs.getString("lid")?.toString() ?? ""; // Use null-aware operator for safety
    String url = "$ip/api/view_food_donation";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData.containsKey('data')) {
          setState(() {
            messageData = List<Map<String, dynamic>>.from(jsonData['data']);
          });
        } else {
          print('Failed to fetch donations: Data key not found');
        }
      } else {
        print('Failed to fetch donations. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching donations: $error');
    }
  }
  Future<void> confirm_menu(String food_req_id, int index, BuildContext context) async {
    try {
      final sh = await SharedPreferences.getInstance();
      String url = sh.getString("url") ?? "";
      String lid = sh.getString("lid") ?? "";

      var response = await http.post(
        Uri.parse(url + "/api/confirm_food"),
        body: {'lid': lid, 'food_request_id': food_req_id},
      );

      var jsonData = json.decode(response.body);
      String status = jsonData['status'].toString();

      if (status == "true") {
        setState(() {
          // messageData.removeAt(index);
        });
        print('Appointment deleted successfully!');
      } else {
        print('Failed to delete appointment: ${jsonData['message']}');
      }
    } catch (e) {
      print('Error deleting appointment: $e');
    }
  }
  Future<String> _getIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    return sh.getString("url") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: messageData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : FutureBuilder<String>(
          future: _getIpAddress(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              String ip = snapshot.data ?? "";
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              size: 15.0,
                            ),
                          ),
                          Text(
                            "Donor Detail",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 48.0),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () {
                              fetchBooking(); // Call your fetch function to refresh data
                            },
                          ),
                        ],
                      ),
                      Center(
                        child: CircleAvatar(
                          radius: 50.0,
                          child: Image.asset("assets/food_don.png"),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        "Donation Details",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: messageData.length,
                        itemBuilder: (context, index) {
                          // Parse and format date
                          DateTime parsedDate;
                          try {
                            parsedDate = DateTime.parse(messageData[index]['date']);
                          } catch (e) {
                            parsedDate = DateTime.now(); // Default value or handle parsing error
                          }
                          String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                            margin: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFE0EEEF),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: [
                                TwoTexts("Day", messageData[index]['day'] ?? ''),
                                TwoTexts("Date", formattedDate), // Display formatted date
                                SizedBox(height: 10),
                                messageData[index]['file_upload'] == "pending"
                                    ? Text("image pending")
                                    : GestureDetector(
                                  onTap: () {
                                    if (messageData[index]['status'] =='pending')
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Menu Confirmation"),
                                          content: Text("Do you confirm this menu?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                final food_req_id = messageData[index]['food_request_id'].toString();
                                                confirm_menu(food_req_id,index, context);
                                              },
                                              child: Text("Confirm"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Image.network(
                                    ip + "/" + messageData[index]['file_upload'],
                                    height: 300,
                                    width: double.infinity,
                                  ),
                                ),
                                TwoTexts("Status", messageData[index]['status'] ?? ''),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),

    );
  }
}

class TwoTexts extends StatelessWidget {
  final String heading;
  final String text;

  TwoTexts(this.heading, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              heading,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
