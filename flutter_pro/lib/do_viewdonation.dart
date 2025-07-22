import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DonorPage extends StatefulWidget {
  const DonorPage({Key? key}) : super(key: key);

  @override
  _DonorPageState createState() => _DonorPageState();
}

class _DonorPageState extends State<DonorPage> {
  List<Map<String, dynamic>> messageData = [];
  List<Map<String, dynamic>> messageData1 = [];
  List<Map<String, dynamic>> messageData2 = [];

  @override
  void initState() {
    super.initState();
    fetchBooking();
    view_donor();
  }

  void fetchBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String lid = prefs.getString("lid").toString();
    String url = ip + "/api/view_donation_item";

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
        print('Failed to fetch donations. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching donations: $error');
    }
  }

  void view_donor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String lid = prefs.getString("lid").toString();
    String url = ip + "/api/view_donor";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'lid': lid},
      );
      var jsonData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          messageData1 = List<Map<String, dynamic>>.from(jsonData['data']);
        });
      } else {
        print('Failed to fetch donor details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching donor details: $error');
    }
  }

  Future<String> _getIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("url") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: messageData.isEmpty || messageData1.isEmpty
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
                          SizedBox(
                            width: 48.0,
                          ),
                        ],
                      ),
                      Center(
                        child: CircleAvatar(
                          radius: 50.0,
                          child: Image.asset("assets/Heart.png"),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      if (messageData1.isNotEmpty)
                        Center(
                          child: Text(
                            messageData1[0]['danme'] ?? '',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (messageData1.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE0EEEF),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: EdgeInsets.all(10.0),
                                margin: EdgeInsets.all(10.0),
                                child: Text(
                                  messageData1[0]['dphone'] ?? '',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE0EEEF),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: EdgeInsets.all(10.0),
                                margin: EdgeInsets.all(10.0),
                                child: Text(
                                  messageData1[0]['demail'] ?? '',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 10.0),
                      if (messageData1.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Personal Information",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 15.0),
                              margin: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFE0EEEF),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                children: [
                                  TwoTexts("Date of Birth",
                                      messageData1[0]['ddateofbirth'] ?? ''),
                                  TwoTexts("Occupation",
                                      messageData1[0]['doccupation'] ?? ''),
                                  TwoTexts("Gender",
                                      messageData1[0]['dgender'] ?? ''),
                                  TwoTexts(
                                      "City", messageData1[0]['dcity'] ?? ''),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 15.0),
                            margin: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFE0EEEF),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: [
                                TwoTexts("Added",
                                    messageData[index]['date'] ?? ''),
                                TwoTexts("Donation Item",
                                    " ${messageData[index]['item'] ?? ''}"),
                                TwoTexts("Type",
                                    " ${messageData[index]['type'] ?? ''}"),
                                TwoTexts("Total Quantity",
                                    "${messageData[index]['qty'] ?? ''}"),
                                TwoTexts("Reply",
                                    messageData[index]['reply'] ?? ''),
                                TwoTexts("Status",
                                    "${messageData[index]['status'] ?? ''}"),
                                TwoTexts("Pick up Option",
                                    "${messageData[index]['pickup_option'] ??
                                        ''}"),
                                SizedBox(height: 10),
                                messageData[index]['file_upload'] == "pending"
                                    ? Text("image pending")
                                    : Image.network(
                                  ip + "/" +
                                      messageData[index]['file_upload'],
                                  height: 300,
                                  width: double.infinity,
                                ),
                                // Conditional IconButton
                                if (messageData[index]['pickup_option'] ==
                                    'Pick Up')
                                  IconButton(
                                    icon: Icon(Icons.person),
                                    color: Colors.blue,
                                    onPressed: () {
                                      _showVolunteerDetails(context,
                                          messageData[index]['donation_item_id'].toString());
                                    },
                                  ),
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

  void _showVolunteerDetails(BuildContext context, String? donation_item_id) async {
    await view_vol(donation_item_id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Volunteer Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: messageData2.isEmpty
                ? [Text("No volunteer details available.")]
                : messageData2.map((volunteer) {
              return Column(
                children: [
                  TwoTexts("Name", volunteer['vname'] ?? ''),
                  TwoTexts("Phone", volunteer['phone'] ?? ''),
                  TwoTexts("Email", volunteer['email'] ?? ''),
                  TwoTexts("Gender", volunteer['gender'] ?? ''),
                  if (volunteer['file_upload'] != "pending")
                    Image.network(
                      ip + "/" + volunteer['file_upload'],
                      height: 100,
                      width: 100,
                    ),
                ],
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> view_vol(String? donation_item_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String url = ip + "/api/view_volunteer";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'donation_item_id': donation_item_id},
      );
      var jsonData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          messageData2 = List<Map<String, dynamic>>.from(jsonData['data']);
        });
      } else {
        print('Failed to fetch volunteer details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching volunteer details: $error');
    }
  }
}

class TwoTexts extends StatelessWidget {
  final String text1;
  final String text2;

  TwoTexts(this.text1, this.text2);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text1,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(text2),
      ],
    );
  }
}