import 'dart:convert';
import 'dart:math'; // For generating OTP
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart'; // Import Lottie package
import 'package:telephony/telephony.dart'; // For sending SMS

void main() {
  runApp(Pickup());
}

class Pickup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pickup Now',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyJobOrdersPage(),
    );
  }
}

class MyJobOrdersPage extends StatefulWidget {
  @override
  _MyJobOrdersPageState createState() => _MyJobOrdersPageState();
}

class _MyJobOrdersPageState extends State<MyJobOrdersPage> {
  List<Map<String, dynamic>> messageData = [];
  List<bool> isSelected = [false, true, false];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String categoryUrl = ip + "/api/vol_view_pickup";

      var data = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      var jsonData = json.decode(data.body);
      String status = jsonData['status'].toString();

      if (status == "true") {
        setState(() {
          messageData = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      } else {
        // Handle error status if needed
        print("API returned error status.");
      }
    } catch (e) {
      print("Error: $e");
      // Handle any errors that occur during the HTTP request.
    }
  }

  void _handleToggleButton(int index) {
    setState(() {
      for (int i = 0; i < isSelected.length; i++) {
        isSelected[i] = i == index;
      }
    });
    // Add navigation logic for toggle buttons if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Ongoing Request'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('All Request'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Ongoing'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Completed '),
                ),
              ],
              isSelected: isSelected,
              onPressed: _handleToggleButton,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messageData.length,
              itemBuilder: (context, index) {
                return JobCard(
                  item: "Item: ${messageData[index]['item'] ?? 'Item Not Available'}",
                  dname: "Donor Name: ${messageData[index]['dname'] ?? 'Name Not Available'}",
                  status: messageData[index]['status'] ?? "Status Not Available",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailPage(
                          data: messageData[index],
                          loadMessages: _loadMessages, // Pass the loadMessages function
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String item;
  final String dname;
  final String status;
  final VoidCallback onTap;

  const JobCard({
    Key? key,
    required this.item,
    required this.dname,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        title: Text(item),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dname),
            Text(status),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class JobDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function loadMessages; // Function to reload messages

  const JobDetailPage({
    Key? key,
    required this.data,
    required this.loadMessages,
  }) : super(key: key);

  @override
  _JobDetailPageState createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  final Telephony telephony = Telephony.instance;
  TextEditingController otpController = TextEditingController();
  bool _isProcessing = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;

  Future<void> _sendMessage(String donationItemId, String donorPhone) async {
    setState(() {
      _isProcessing = true; // Set processing state to true
    });

    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String sendMessageUrl = ip + "/api/vol_updatestatus_pickup";

      var response = await http.post(
        Uri.parse(sendMessageUrl),
        body: {
          'lid': lid,
          'donation_item_id': donationItemId,
        },
      );

      if (response.statusCode == 200) {
        print('Message sent successfully');
        _sendOtp(donorPhone); // Send OTP after updating the status
      } else {
        print('Error sending message: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isProcessing = false; // Set processing state to false
      });
    }
  }
  final SmsSendStatusListener listener = (SendStatus status) {
    // Handle the status
    print(status);
  };

  // void _sendOtp(String phoneNumber) async {
  //   bool? permissionsGranted = await telephony.requestSmsPermissions;
  //   print(permissionsGranted);  // Check if permissions are granted
  //   bool? canSendSms = await telephony.isSmsCapable;
  //   print(canSendSms); // Check if SMS is capable
  //   SimState simState = await telephony.simState;
  //   print(simState);  // Check SIM state
  //
  //   // Generate a random 6-digit OTP
  //   final random = Random();
  //   final otp = (100000 + random.nextInt(900000)).toString();
  //   //
  //   // // Store OTP in SharedPreferences
  //   final sh = await SharedPreferences.getInstance();
  //   await sh.setString('otp', otp);
  //
  //   // Send the SMS with the generated OTP
  //   telephony.sendSms(
  //     to: phoneNumber,
  //     message: "Dear, $otp for your  generous . Together, we make a difference!\n\n- Aged Well Senior Care \nLajpat Nagar-II, New Delhi, India\nPhone : +91-11-35667538",
  //     statusListener: listener,
  //   );
  // }

  void _sendOtp(String phoneNumber) async {
    final random = Random();
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    print(permissionsGranted);  // Check if permissions are granted
    bool? canSendSms = await telephony.isSmsCapable;
    print(canSendSms); // Check if SMS is capable
    SimState simState = await telephony.simState;
    print(simState);  // Check SIM state
    final otp = (100000 + random.nextInt(900000)).toString(); // Generates a 6-digit OTP


    // Store OTP in SharedPreferences for verification
    final sh = await SharedPreferences.getInstance();
    await sh.setString('otp', otp);
    // Your OTP is $otp. Please use it to confirm the pickup.
    // Send the SMS with the generated OTP


    telephony.sendSms(
      to: phoneNumber,
      message: "Dear,Your OTP $otp  res generous donation. Together, we make a difference!\n\n- Aged Well Senior Care \nLajpat Nagar-II, New Delhi, India\nPhone : +91-11-35667538",

      statusListener: listener,
    );

    setState(() {
      _isOtpSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP sent to $phoneNumber')),
    );
  }

  void _verifyOtp() async {
    final sh = await SharedPreferences.getInstance();
    String? storedOtp = sh.getString('otp');

    if (storedOtp == otpController.text) {
      // OTP is correct, proceed to show the success animation
      setState(() {
        _isOtpVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verified successfully.')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessAnimationPage(),
        ),
      );
    } else {
      // OTP is incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect OTP. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aged Well Pickup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isOtpSent) ...[
              Text(
                widget.data['item'] ?? "Item Not Available",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("Quantity: ${widget.data['qty'] ?? 'quantity Not Available'}"),
              Text("Type: ${widget.data['type'] ?? 'type Not Available'}"),
              Text("Date: ${widget.data['date'] ?? 'date Not Available'}"),
              Text("Time: ${widget.data['time'] ?? 'time Not Available'}"),
              SizedBox(height: 20),
              Text(
                'Donor Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FutureBuilder<String>(
                future: _getIpAddress(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  String ipAddress = snapshot.data ?? "";
                  String imageUrl = ipAddress + "/" + (widget.data['dp_image'] ?? ""); // Adjust as per your data structure
                  print(imageUrl); // Debugging print statement
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : AssetImage('assets/default_avatar.png') as ImageProvider, // Example of providing a default image
                    ),
                    title: Text("Donor Name: ${widget.data['dname'] ?? 'Name Not Available'}"),
                    subtitle: Text("Pickup Address:${widget.data['pickup_address'] ?? 'Address Not Available'}"),
                  );
                },
              ),
              Spacer(),
              Center(
                child: _isProcessing
                    ? CircularProgressIndicator() // Show CircularProgressIndicator while processing
                    : ElevatedButton(
                  onPressed: () {
                    _sendMessage(
                      widget.data['donation_item_id'].toString(),
                      widget.data['dphone'].toString(),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white), // Example icon for pickup
                      SizedBox(width: 10),
                      Text('Pickup Job'),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ] else ...[
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyOtp,
                child: Text('Verify OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<String> _getIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    return sh.getString("url") ?? "";
  }
}

class SuccessAnimationPage extends StatefulWidget {
  @override
  _SuccessAnimationPageState createState() => _SuccessAnimationPageState();
}

class _SuccessAnimationPageState extends State<SuccessAnimationPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/ani2.json', // Ensure the path is correct
              width: 500,
              height: 500,
            ),
            SizedBox(height: 20),
            Text(
              'Pickup Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
