import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class do_payment extends StatefulWidget {
  const do_payment({Key? key}) : super(key: key);

  @override
  _do_paymentState createState() => _do_paymentState();
}

class _do_paymentState extends State<do_payment> {
  List<Map<String, dynamic>> messageData = [];
  List<Map<String, dynamic>> messageData1 = [];

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
    String url = ip + "/api/view_donation_payment";

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
        print('Failed to fetch donations. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching donations: $error');
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
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                                margin: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE0EEEF),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  children: [
                                    TwoTexts("Date of Birth", messageData1[0]['ddateofbirth'] ?? ''),
                                    TwoTexts("Occupation", messageData1[0]['doccupation'] ?? ''),
                                    TwoTexts("Gender", messageData1[0]['dgender'] ?? ''),
                                    TwoTexts("City", messageData1[0]['dcity'] ?? ''),
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
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                                margin: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE0EEEF),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  children: [
                                    TwoTexts("Added", messageData[index]['date'] ?? ''),
                                    TwoTexts("Donation Amount",
                                        "\$ ${messageData[index]['amount'] ?? ''}"),

                                    TwoTexts("Reply", messageData[index]['reply'] ?? ''),
                                    SizedBox(height: 10),
                                    messageData[index]['file_upload'] == "pending"
                                        ? Text("image pending")
                                        : Image.network(
                                      ip + "/" + messageData[index]['file_upload'],
                                      height: 300,
                                      width: double.infinity,
                                    ),
                                  ],
                                ),

                              );
                            }),
                      ],
                    ),

                  )
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
