 import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Import the package

import 'package:flutter/material.dart';
import 'package:flutter_pro/vol_add_review.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import 'CreateAccountPage.dart';
import 'Drawer.dart';
import 'donor_reg.dart';
import 'intro_screen.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'login_demo.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingPage(),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final int _timerDuration = 5;
  final ScrollController _scrollController = ScrollController();

  final PageController _pageController = PageController();
  List<Map<String, dynamic>> messageData = [];
  List<Map<String, dynamic>> messageData2 = [];
  List<Map<String, dynamic>> messageData3 = [];
  List<Map<String, dynamic>> messageData4 = [];
  bool _isPressed = false;
  List<Map<String, dynamic>> messageData5 = [];
  List<Map<String, dynamic>> messageData6 = [];
  bool _showMore = false;
  bool _isVisible=true;
  Future<void> viewreply() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String categoryUrl = ip + "/api/userviewreply";

      var response = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        String status = jsonData['status'].toString();

        if (status == "true") {
          // Assuming the 'data' is a Map with 'donation_items' and 'donation_payments' as keys
          Map<String, dynamic> data = jsonData['data'];

          // Parse donation items if available
          if (data['donation_items'] != null) {
            List<Map<String, dynamic>> donationItems = List<Map<String, dynamic>>.from(data['donation_items']);
            // Process donationItems as needed
          }

          // Parse donation payments if available
          if (data['donation_payments'] != null) {
            List<Map<String, dynamic>> donationPayments = List<Map<String, dynamic>>.from(data['donation_payments']);
            // Process donationPayments as needed
          }

          setState(() {
            // Update your state with the parsed data
            messageData4 = List<Map<String, dynamic>>.from(data['donation_items'] ?? []);
            messageData5 = List<Map<String, dynamic>>.from(data['donation_payments'] ?? []);
          });
        } else {
          // Handle the case where the status is not "true"
          print('API returned an error status: $status');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      // Handle any errors that occur during the HTTP request.
    }
  }

  Future<void> _loadMessages() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String categoryUrl = ip + "/api/demo_video";

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
  Future<void> viewreview() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String categoryUrl = ip + "/api/viewreview";

      var data = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      var jsonData = json.decode(data.body);
      String status = jsonData['status'].toString();

      if (status == "true") {
        setState(() {
          messageData3 = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      } else {
        // Handle error status if needed
      }
    } catch (e) {
      print("Error: $e");
      // Handle any errors that occur during the HTTP request.
    }
  }
  Future<void> _loadMessages2() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String categoryUrl = ip + "/api/article";

      var data = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      var jsonData = json.decode(data.body);
      String status = jsonData['status'].toString();

      if (status == "true") {
        setState(() {
          messageData2 = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      } else {
        // Handle error status if needed
      }
    } catch (e) {
      print("Error: $e");
      // Handle any errors that occur during the HTTP request.
    }
  }
  Future<void> _loadMessages3() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String categoryUrl = ip + "/api/vol_view_reward";

      var data = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      var jsonData = json.decode(data.body);
      String status = jsonData['status'].toString();

      if (status == "true") {
        setState(() {
          messageData6 = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
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
  void initState() {
    super.initState();
    _loadMessages();
    _loadMessages2();
    _loadMessages3();
    viewreview();
    viewreply();
    // Start timer for automatic sliding
    Timer.periodic(Duration(seconds: _timerDuration), (timer) {
      if (_pageController.hasClients) {
        // Calculate the next page index
        var nextPage = _pageController.page! + 1;
        // Check if next page index exceeds total count, then go back to the first page
        if (nextPage >= _images.length) {
          nextPage = 0;
        }
        // Animate to the next page
        _pageController.animateToPage(
          nextPage.toInt(),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    // Dispose the page controller when not needed
    _pageController.dispose();
    super.dispose();
    _pageController.dispose();
  }

  Future<String> _getIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    return sh.getString("url") ?? "";
  }

  // Function to download the image
  Future<void> _downloadImage(String url) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Storage permission not granted');
        return;
      }

      var dio = Dio();
      var tempDir = await getTemporaryDirectory();
      String savePath = "${tempDir.path}/downloaded_image.jpg";

      await dio.download(url, savePath);

      // Move the file to a more permanent location
      final directory = await getExternalStorageDirectory();
      final path = directory?.path;
      final file = File(savePath);
      if (path != null) {
        await file.copy('$path/downloaded_image.jpg');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image downloaded successfully')),
        );
      }
    } catch (e) {
      print('Error downloading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download image')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Set the desired height here
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white, // Set your desired background color here
          title: Image.asset(
            'assets/ic.png', // Replace with your image path
            height: 200.0,
            width: 180,// Adjust the height as needed
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_circle,
                    size: 40.0, // Set the desired size here
                    color: Colors.teal, // Icon color
                  ),
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ],

        ),

      ),



      drawer: AppDrawer(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Container(
              height: 580, // Adjusted height for better visibility
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/home.jpg"), // Replace with your image URL
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Positioned text
                  Positioned(
                    bottom: 330,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.transparent.withOpacity(0.0), // Semi-transparent background for better readability
                      // Uncomment to show the text
                      // child: Text(
                      //   "“To provide care for the people who once cared for us is one of life's greatest honors.”",
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 19,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                    ),
                  ),
                  // Scroll down arrow
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTapDown: (_) {
                          setState(() {
                            _isPressed = true;
                          });
                        },
                        onTapUp: (_) {
                          setState(() {
                            _isPressed = false;
                          });
                          _scrollDown();
                        },
                        onTapCancel: () {
                          setState(() {
                            _isPressed = false;
                          });
                        },
                        child: Icon(
                          _isPressed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 5),
                    // Add the Lottie animation here
                    Row(
                      children: [

                         // Space between Lottie animation and text
                        Expanded(
                          flex: 2, // Adjust the flex to control the space ratio
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome!',
                                style: TextStyle(
                                  fontSize: 43,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[700],
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                '"Your support nurtures, your kindness heals"',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[700],
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 10),
                              LimitedBox(
                                maxHeight: _showMore ? double.infinity : 60.0,
                                child: Text(

                                  '"Explore how you can make a difference with AgedWell Senior Care. Our application provides a platform for you to contribute through donations and volunteer services, enhancing the well-being and quality of life for our elderly residents."',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 12,
                                  ),
                                  maxLines: _showMore ? 15 : 8,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!_showMore)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showMore = true;
                                    });
                                  },
                                  child: Text(
                                    'Show more',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: Lottie.asset(
                            'assets/animation3.json', // Ensure the path is correct
                            width: 220,
                            height: 200,
                          ),
                        ),
                      ],
                    ),

                        Center(
                          child: SizedBox(
                            width: 350,
                            height: 50,// Set the button width
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => IndividualAccountSetup(),
                                ));
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white
                                , backgroundColor: Colors.teal, // Set the text color
                              ),
                              child: Text(
                                'Join As A Volunteer',
                                textAlign: TextAlign.center, // Center align text within the button
                                style: TextStyle(
                                  fontSize: 16, // Set font size if needed
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: messageData2.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Show download option
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: Icon(Icons.download),
                                        title: Text('Download Image'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          String ipAddress = await _getIpAddress();
                                          String imageUrl =
                                              "$ipAddress/${messageData2[index]['article'] ?? ''}";
                                          await _downloadImage(imageUrl);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    FutureBuilder<String>(
                                      future: _getIpAddress(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        }
                                        if (snapshot.hasError) {
                                          return Text('Error: ${snapshot.error}');
                                        }
                                        String ipAddress = snapshot.data ?? "";
                                        String imageUrl =
                                            "$ipAddress/${messageData2[index]['article'] ?? ''}";
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            imageUrl,
                                            width: 292,
                                            height: 500,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons.error,
                                                color: Colors.red,
                                                size: 100,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            messageData2[index]['dp_desc'] ?? '',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),


                        // List of Items
                        SizedBox(height: 10),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  "Giving with love is giving a piece of your heart✨",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                FutureBuilder<String>(
                                  future: _getIpAddress(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    if (!snapshot.hasData || snapshot.data == null) {
                                      return Text('No IP Address');
                                    }

                                    String ipAddress = snapshot.data!;

                                    // Combine the two lists
                                    List<dynamic> combinedData = [];
                                    if (messageData4 != null) combinedData.addAll(messageData4);
                                    if (messageData5 != null) combinedData.addAll(messageData5);

                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: combinedData.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          dynamic data = entry.value;
                                          String imageUrl = "$ipAddress/${data['file_upload'] ?? ''}";

                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => SecondPage(
                                                    heroTag: index,
                                                    imageUrl: imageUrl,
                                                    reply: data['reply'] ?? 'No Title',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 16.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 200,
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      image: DecorationImage(
                                                        image: NetworkImage(imageUrl),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    data['dname'] ?? 'No Title',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontStyle: FontStyle.italic,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 10),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        )


                      ]


                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 70,),
                  SizedBox(
                    width: 150,
                    height: 50,// Set the button width
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => donor_reg(),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white
                        , backgroundColor: Colors.teal, // Set the text color
                      ),
                      child: Text(
                        'Donate Now',
                        textAlign: TextAlign.center, // Center align text within the button
                        style: TextStyle(
                          fontSize: 16, // Set font size if needed
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    'Together We Can Help',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                    textAlign: TextAlign.left,
                  ),

                ],
              ),
              Card(
                elevation: 15, // Increased elevation for a more pronounced shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // More rounded corners
                ),
                color: Colors.white, // Background color of the card
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center, // Align children to the start
                    children: <Widget>[
                      Text(
                        "Voices of Our Volunteers ✨",
                        style: TextStyle(
                          fontSize: 20, // Increased font size
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,  // Darker text color
                        ),
                      ),
                      SizedBox(height: 10),
                      FutureBuilder<String>(
                        future: _getIpAddress(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Center(child: Text('No IP Address'));
                          }
                          String ipAddress = snapshot.data!;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: messageData3.map((data) {
                                String imageUrl = "$ipAddress/${data['p_image'] ?? ''}";
                                double rating = double.tryParse(data['rate'] ?? '0') ?? 0;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Container(
                                    width: 220, // Slightly wider container
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200], // Light gray background for the item
                                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 4),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                                          child: Container(
                                            width: double.infinity,
                                            height: 140,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            data['review'] ?? 'No Review',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87, // Darker text color
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: SmoothStarRating(
                                            allowHalfRating: true,
                                            onRatingChanged: (value) {
                                              rating = value;
                                              print("New rating: $value");
                                            },
                                            starCount: 5,
                                            rating: rating,
                                            size: 24.0, // Larger star size
                                            filledIconData: Icons.star,
                                            halfFilledIconData: Icons.star_half,
                                            defaultIconData: Icons.star_border,
                                            color: Colors.amber,
                                            borderColor: Colors.amber,
                                            spacing: 0.0,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),

                            ),

                          );
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              Card(
                elevation: 8, // Slightly higher elevation for a more pronounced shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // More rounded corners
                ),
                color: Colors.grey[100], // Light grey background for a softer look
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Top Volunteers Spotlight 🌟",
                        style: TextStyle(
                          fontSize: 20, // Larger font size
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey, // Different text color
                        ),
                      ),
                      SizedBox(height: 12),
                      FutureBuilder<String>(
                        future: _getIpAddress(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return Center(child: Text('No IP Address'));
                          }
                          String ipAddress = snapshot.data!;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: messageData6.map((data) {
                                String imageUrl = "$ipAddress/${data['p_image'] ?? ''}";

                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Container(
                                    width: 220, // Slightly wider container
                                    decoration: BoxDecoration(
                                      color: Colors.white, // White background for the item
                                      borderRadius: BorderRadius.circular(12.0), // More rounded corners
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 4),
                                          blurRadius: 8, // Increased blur radius
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                                          child: Container(
                                            width: double.infinity,
                                            height: 160, // Slightly taller container for images
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            data['vname'] ?? 'No Title',
                                            style: TextStyle(
                                              fontSize: 16, // Larger font size for the name
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87, // Darker text color
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            "Appointment Count: ${data['appointment_count'] ?? 'N/A'}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54, // Lighter text color
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text(
                                            "Total Working Hours: ${data['total_working_hours'] ?? 'N/A'}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54, // Lighter text color
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Keep\nSpreading\nLove!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(width: 20),
                  Lottie.asset(
                    'assets/love.json', // Ensure the path is correct
                    width: 120,
                    height: 200,
                  ),
                ],
              ),
              SizedBox(height: 10),



            ]

        ),
      ),
    );
  }
}
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Keep\nSpreading\nLove!',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(width: 20),

                ],
              ),
              SizedBox(height: 10),
              Text(
                "with Ketto's Social Impact Plan",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  final int heroTag;
  final String imageUrl;
  final String reply;

  const SecondPage({
    Key? key,
    required this.heroTag,
    required this.imageUrl,
    required this.reply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Page")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'hero_$heroTag',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              reply,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}


final List<String> _images1 = [
  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQYd5D6hZglCFWUKldIOijSo5V5UftH-8cpjA&s',
  'https://www.shutterstock.com/image-photo/elderly-woman-using-walker-receives-260nw-2273750445.jpg',
  'https://images.squarespace-cdn.com/content/v1/60c650ed28ec9e0a89542605/1623609661521-XPTELYBICDAFNSD38XK8/Cover-Get-Involved.jpg',
  'https://shabiba.eu-central-1.linodeobjects.com/2023/04/1680975210-1680975210-o6rmhoccumlq.jpg',
  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT-qe-5IIXo4ptSnoxxtzMekB8zMWVnwfmF_aG06HHv61Jbr31amJUtZ6xpU9iAv0ff6C4&usqp=CAU',
  'https://patch.com/img/cdn20/shutterstock/23263837/20211111/012034/styles/patch_image/public/shutterstock-1818828947___11131518648.jpg'
];

final List<String> _images = [
  'https://sundayguardianlive.com/wp-content/uploads/2018/09/p4-20.jpg',
  'https://thumbs.dreamstime.com/b/elderly-care-29076770.jpg',
];

class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Text('Home Page Content'),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.purple.shade100,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'AgedWell',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30,),
          ListTile(
            leading: Icon(Icons.home_filled),
            title: Text('Home '),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OnboardingPage(), // Replace with your sign-up page widget
                ),
              );             },
          ),
          ListTile(
            leading: Icon(Icons.handshake),
            title: Text('Donor'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => donor_reg(), // Replace with your sign-up page widget
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Volunteers '),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IndividualAccountSetup(), // Replace with your sign-up page widget
                ),
              );             },
          ),

          SizedBox(height: 30),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginDemo(), // Replace with your sign-up page widget
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.teal, // Text color when button is pressed
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Sign In'),
              )

          ),
          // SizedBox(height: 10),
          // Center(
          //   child: TextButton(
          //     onPressed: () {
          //       // Handle the login action
          //     },
          //     child: Text('Already a User? Log In'),
          //   ),
          // ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TextButton(
                //   onPressed: () {
                //     // Handle the terms and conditions action
                //   },
                //   child: Text('Terms & Conditions'),
                // ),
                // TextButton(
                //   onPressed: () {
                //     // Handle the privacy policy action
                //   },
                //   child: Text('Privacy Policy'),
                // ),
                // SizedBox(height: 10),
                // Text(
                //   'App Version: 3.2.3 (473)',
                //   style: TextStyle(
                //     color: Colors.grey,
                //     fontSize: 12,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

