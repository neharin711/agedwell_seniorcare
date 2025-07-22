 import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pro/vol_com_work.dart';
import 'package:flutter_pro/vol_home.dart';
import 'package:flutter_pro/vol_pickup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart'; // Import Lottie package

void main() {
  runApp(request());
}

class request extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pickup Now',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyrequestPage(),
    );
  }
}

class MyrequestPage extends StatefulWidget {
  @override
  _MyJobOrdersPageState createState() => _MyJobOrdersPageState();
}

class _MyJobOrdersPageState extends State<MyrequestPage> {
  List<Map<String, dynamic>> messageData = [];
  List<bool> isSelected = [true, false, false];
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
      String categoryUrl = ip + "/api/vol_view_request";

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
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => request()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Pickup()), // Replace with your ongoing jobs page
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Completed()), // Replace with your completed jobs page
        );
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePageIndividual(),
              ),
            );
          },
        ),
        title: Text('All Request'),
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
                  child: Text('Ongoing '),
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
                return JobCardrequest(
                  item: "Item: ${messageData[index]['item'] ?? 'Item Not Available'}",
                  dname: "Donor Name: ${messageData[index]['dname'] ?? 'Name Not Available'}",
                  status: messageData[index]['status'] ?? "Status Not Available",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobrequestDetailPage(
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

class JobCardrequest extends StatelessWidget {
  final String item;
  final String dname;
  final String status;
  final VoidCallback onTap;

  const JobCardrequest({
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

class JobrequestDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function loadMessages; // Function to reload messages

  const JobrequestDetailPage({
    Key? key,
    required this.data,
    required this.loadMessages,
  }) : super(key: key);

  @override
  _JobrequestDetailPageState createState() => _JobrequestDetailPageState();
}

class _JobrequestDetailPageState extends State<JobrequestDetailPage> {
  bool _isProcessing = false;

  Future<void> _sendMessage(String donationItemId) async {
    setState(() {
      _isProcessing = true; // Set processing state to true
    });

    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String sendMessageUrl = ip + "/api/vol_updatestatus";

      var response = await http.post(
        Uri.parse(sendMessageUrl),
        body: {
          'lid': lid,
          'donation_item_id': donationItemId,
        },
      );

      if (response.statusCode == 200) {
        print('Message sent successfully');
        widget.loadMessages(); // Reload messages after sending message
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessAnimationPage(), // Navigate to success animation page
          ),
        );
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
                    backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : AssetImage('assets/default_avatar.png'), // Example of providing a default image
                  ),
                  title: Text("Donor Name: ${widget.data['dname'] ?? 'Name Not Available'}"),
                  subtitle: Text(
                      "Pickup Address:${widget.data['pickup_address'] ?? 'Address Not Available'}"),
                );
              },
            ),
            Spacer(),
            Center(
              child: _isProcessing
                  ? CircularProgressIndicator() // Show CircularProgressIndicator while processing
                  : ElevatedButton(
                onPressed: () {
                  _sendMessage(widget.data['donation_item_id'].toString());
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white), // Example icon for pickup
                    SizedBox(width: 10),
                    Text('Accept Request'),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
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
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animation2.json', // Ensure the path is correct
              width: 300,
              height: 300,
            ),
            SizedBox(height: 20),
            Text(
              'Request Accept Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
