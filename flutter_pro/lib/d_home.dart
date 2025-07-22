
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pro/phone_message.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'do_foodrequest.dart';
import 'do_viewdonation.dart';
import 'do_viewdonationpayment.dart';
import 'don_chat.dart';

import 'donor_pro_update.dart';
import 'donor_view_requ.dart';
import 'intro_screen.dart';
import 'login.dart';

import 'shared/widgets/gradient_background.dart';

class d_home extends StatefulWidget {
  const d_home({Key? key}) : super(key: key);

  @override
  State<d_home> createState() => DHomeState();
}

class DHomeState extends State<d_home> {
  List<Map<String, dynamic>> messageData = [];

  @override
  void initState() {
    super.initState();
    _loadUnreadNotifications();
    fetchBooking();
  }

  int _currentIndex = 0;
  int notificationCount = 0;
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        _showDonationDialog();
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => do_payment(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonorPage(),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodRequestPage(),
          ),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodRequestPage(),
          ),
        );
        break;
      default:
        break;
    }
  }

  Future<void> _logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IntroScreen(),
      ),
    );
  }

  void _showDonationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Choose Donation Type',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white, // Skin color background
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonationAmountPage(),
                    ),
                  );
                },
                child: Text(
                  'Payment',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 190, 190, 190),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DonationItemPage(),
                    ),
                  );
                },
                child: Text(
                  'Donation Item',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 190, 190, 190),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _getProfilePhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ipAddress = prefs.getString("url") ?? ""; // Get the base URL
    String profilePhotoPath = prefs.getString('pimage') ?? ''; // Get the profile photo path
    return '$ipAddress/$profilePhotoPath'; // Construct the full URL
  }

  Future<void> _markNotificationsAsRead() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      if (!ip.startsWith('http://') && !ip.startsWith('https://')) {
        ip = 'http://$ip';
      }
      String markNotificationsAsReadUrl = "$ip/api/mark_notifications_as_read";

      var response = await http.post(Uri.parse(markNotificationsAsReadUrl), body: {'lid': lid});
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        String status = jsonData['status'].toString();

        if (status == "true") {
          setState(() {
            notificationCount = 0; // Clear the notification count
          });
        } else {
          print("Failed to mark notifications as read.");
        }
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error marking notifications as read: $e");
    }
  }
  Future<void> _loadUnreadNotifications() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      if (!ip.startsWith('http://') && !ip.startsWith('https://')) {
        ip = 'http://$ip';
      }
      String unreadNotificationsUrl = "$ip/api/unread_notifications";

      var response = await http.post(Uri.parse(unreadNotificationsUrl), body: {'lid': lid});
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        String status = jsonData['status'].toString();

        if (status == "true") {
          setState(() {
            notificationCount = int.parse(jsonData['count'].toString());
          });
        } else {
          print("Failed to fetch unread notifications.");
        }
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching unread notifications: $e");
    }
  }

  Future<void> fetchBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String lid = prefs.getString("lid")?.toString() ?? ""; // Use null-aware operator for safety
    String url = "$ip/api/view_donor_req_cat";

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
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(Icons.mark_unread_chat_alt_outlined),
                      onPressed: () async {
                        await _markNotificationsAsRead(); // Mark notifications as read
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrgChatScreen1(), // Replace with your actual widget
                          ),
                        );
                      },
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '$notificationCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                FutureBuilder<String>(
                  future: _getProfilePhoto(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Loading indicator
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return IconButton(
                        icon: Icon(Icons.logout),
                        onPressed: _logout,
                      ); // Fallback to logout icon if there is an error or no data
                    }else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return IconButton(
                        icon: Icon(Icons.logout),
                        onPressed: _logout,
                      ); // Fallback to logout icon if there is an error or no data
                    } else {
                      return PopupMenuButton<String>(
                        icon: CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data!),
                          radius: 15.0,
                        ),
                        onSelected: (String result) {
                          switch (result) {
                            case 'logout':
                              _logout();
                              break;
                            case 'profile':
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DProUpdate(), // Replace with your actual widget
                                ),
                              );
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'profile',
                            child: Text('Update Profile'),
                          ),
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: Text('Logout'),
                          ),
                        ],
                      );
                    }

                  },
                ),
              ],
            ),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFE3BD8D),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          // selectedLabelStyle: TextStyle(color: Colors.black),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              tooltip: "Home",
              icon: Icon(Icons.home, color: Colors.black),
              label: "Home",
              backgroundColor: Color(0xFFC7E2E4),
            ),
            BottomNavigationBarItem(
              tooltip: "Donation",
              icon: Icon(Icons.favorite, color: Colors.black),
              label: "Donation",

              backgroundColor: Color(0xFFC7E2E4),
            ),
            // BottomNavigationBarItem(
            //   tooltip: "Chat",
            //   icon: Icon(Icons.mark_unread_chat_alt_outlined, color: Colors.black),
            //   label: "Chat",
            //   backgroundColor: Color(0xFFC7E2E4),
            // ),
            BottomNavigationBarItem(
              tooltip: "Payment",
              icon: Icon(Icons.payment, color: Colors.black),
              label: "Payment",
              backgroundColor: Color(0xFFC7E2E4),
            ),
            BottomNavigationBarItem(
              tooltip: "Item",
              icon: Icon(Icons.bed, color: Colors.black),
              label: "Item",
              backgroundColor: Color(0xFFC7E2E4),
            ),
            BottomNavigationBarItem(
              tooltip: "Food",
              icon: Icon(Icons.fastfood_outlined, color: Colors.black),
              label: "Food",
              backgroundColor: Color(0xFFC7E2E4),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: <Widget>[
            const UniDirectionalBackground(),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: const AssetImage("assets/uu7.png"),
                    height: 300.h,
                    width: double.infinity,
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: messageData.length,
                      itemBuilder: (context, index) {
                        return JobCardrequest(
                          item: "Requirements for: ${messageData[index]['d_cat'] ?? 'category Not Available'}",
                          // dname: "Donor Name: ${messageData[index]['dname'] ?? 'Name Not Available'}",
                          // status: messageData[index]['status'] ?? "Status Not Available",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => donor_view_reqPage(
                                  d_cat_id: messageData[index]['d_cat_id'].toString(),
                                  // Pass the loadMessages function
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
            ),
          ],
        ),
      ),
    );
  }
}


class JobCardrequest extends StatelessWidget {
  final String item;
  // final String dname;
  // final String status;
  final VoidCallback onTap;

  const JobCardrequest({
    Key? key,
    required this.item,
    // required this.dname,
    // required this.status,
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
            // Text(dname),
            // Text(status),
          ],
        ),

        onTap: onTap,
      ),
    );
  }
}

void main() {
  runApp(DonationAmountPage());
}

class DonationAmountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: CardDetailsScreen(),
    );
  }
}

class CardDetailsScreen extends StatefulWidget {
  @override
  _CardDetailsScreenState createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expMonthController = TextEditingController();
  final TextEditingController _expYearController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  Future<void> sendAmount(String amount) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String sendMessageUrl = ip + "/api/donation_payment";

      var response = await http.post(
        Uri.parse(sendMessageUrl),
        body: {
          'lid': lid,
          'amount': amount,
        },
      );

      if (response.statusCode == 200) {
        print('Message sent successfully');
        // Handle success as needed
      } else {
        print('Error sending message: ${response.statusCode}');
        // Handle error as needed
      }
    } catch (e) {
      print("Error: $e");
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E1), // Skin color background
      appBar: AppBar(
        title: Text('Card Details'),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            CardTypeWidget(
              cardHolderName: _nameController.text,
              cardNumber: _cardNumberController.text,
              expMonth: _expMonthController.text,
              expYear: _expYearController.text,
            ),
            SizedBox(height: 20),
            Text(
              'Name on Card',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: _nameController,
              hintText: 'Giga Tamarashvili',
              onChanged: (value) {
                setState(() {});
              },

            ),
            SizedBox(height: 20),
            Text(
              'Card Number',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: _cardNumberController,
              hintText: '**** **** **** ****',
              onChanged: (value) {
                setState(() {});
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                CardNumberInputFormatter()
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expiration Date',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _expMonthController,
                              hintText: 'MM',
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: CustomTextField(
                              controller: _expYearController,
                              hintText: 'YY',
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CVV',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        controller: _cvvController,
                        hintText: 'XXX',
                        onChanged: (value) {
                          setState(() {});
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3), // Limit input to 3 characters

                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Amount',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: _amountController,
              hintText: 'Amount',
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  String amount = _amountController.text;
                  await sendAmount(amount);
                  final pref = await SharedPreferences.getInstance();
                  String phone = pref.getString("dphone") ?? "";
                  print("phonenumber=$phone");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => messageScreen(phone:phone) // Navigate to success animation page
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Check Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardTypeWidget extends StatelessWidget {
  final String cardHolderName;
  final String cardNumber;
  final String expMonth;
  final String expYear;

  CardTypeWidget({
    required this.cardHolderName,
    required this.cardNumber,
    required this.expMonth,
    required this.expYear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey, // Black card background
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.credit_card,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(width: 10),
              Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            cardNumber.isEmpty ? '**** **** **** ****' : cardNumber,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardHolderName.isEmpty ? 'Card Holder' : cardHolderName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                '${expMonth.isEmpty ? 'MM' : expMonth}/${expYear.isEmpty ? 'YY' : expYear}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  CustomTextField({
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: Colors.black),
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final newText = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i % 4 == 0 && i != 0) newText.write(' ');
      newText.write(text[i]);
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: newValue.selection.copyWith(
        baseOffset: newText.length,
        extentOffset: newText.length,
      ),
    );
  }
}






class DonationItemPage extends StatefulWidget {
  @override
  _DonationItemPageState createState() => _DonationItemPageState();
}

class _DonationItemPageState extends State<DonationItemPage> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _pickupOption = 'Drop'; // Default value for the pickup option

  Future<void> senditem(String item, String quantity, String type, String date, String time, String address, String pickupOption) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String sendMessageUrl = ip + "/api/donation_item";

      var response = await http.post(
        Uri.parse(sendMessageUrl),
        body: {
          'lid': lid,
          'item': item,
          'qty': quantity,
          'type': type,
          'date': date,
          'time': time,
          'pickup': address,
          'pickup_option': pickupOption, // Include pickup option
        },
      );

      if (response.statusCode == 200) {
        print('Message sent successfully');
        // Handle success as needed
      } else {
        print('Error sending message: ${response.statusCode}');
        // Handle error as needed
      }
    } catch (e) {
      print("Error: $e");
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate by Item'),
        backgroundColor: Colors.brown[300],
      ),
      body: Container(
        color: Color(0xFFFFF8E1), // Skin color background
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(
              controller: _itemController,
              label: 'Enter item',
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _quantityController,
              label: 'Enter quantity',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _typeController,
              label: 'Enter type',
            ),
            SizedBox(height: 10),
            _buildDateField(context),
            SizedBox(height: 10),
            _buildTimeField(context),
            SizedBox(height: 10),
            // Radio buttons for pickup option
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Drop'),
                    leading: Radio<String>(
                      value: 'Drop',
                      groupValue: _pickupOption,
                      onChanged: (value) {
                        setState(() {
                          _pickupOption = value!;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Pick Up'),
                    leading: Radio<String>(
                      value: 'Pick Up',
                      groupValue: _pickupOption,
                      onChanged: (value) {
                        setState(() {
                          _pickupOption = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Show the address field only if "Pick Up" is selected
            if (_pickupOption == 'Pick Up')
              _buildTextField(
                controller: _addressController,
                label: 'Enter pickup address',
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Handle the donation item submission
                final item = _itemController.text;
                final quantity = _quantityController.text;
                final type = _typeController.text;
                final date = _dateController.text;
                final time = _timeController.text;
                final address = _pickupOption == 'Pick Up' ? _addressController.text : '';
                await senditem(item, quantity, type, date, time, address, _pickupOption);
                print('Item: $item');
                print('Quantity: $quantity');
                print('Type: $type');
                print('Date: $date');
                print('Time: $time');
                print('Address: $address');
                print('Pickup Option: $_pickupOption');
                final pref = await SharedPreferences.getInstance();
                String phone = pref.getString("dphone") ?? "";
                print("phonenumber=$phone");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => messageScreen(phone: phone), // Navigate to success animation page
                  ),
                );
              },
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Enter date',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return TextField(
      controller: _timeController,
      decoration: InputDecoration(
        labelText: 'Enter time',
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(Icons.access_time),
          onPressed: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              _timeController.text = pickedTime.format(context);
            }
          },
        ),
      ),
    );
  }
}

class SuccessAnimationPage1 extends StatefulWidget {
  @override
  _SuccessAnimationPageState1 createState() => _SuccessAnimationPageState1();
}

class _SuccessAnimationPageState1 extends State<SuccessAnimationPage1> {
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
              'Payment Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}


