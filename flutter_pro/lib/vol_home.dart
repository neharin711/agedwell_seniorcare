import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pro/reward.dart';
import 'package:flutter_pro/vol_pickup.dart';
import 'package:flutter_pro/vol_pro_update.dart';
import 'package:flutter_pro/vol_view_request.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import 'demo_video.dart';
import 'intro_screen.dart';
import 'login.dart';
import 'org_chat_screen.dart';
import 'vol_add_review.dart';
import 'vol_send_appo.dart';
import 'shared/widgets/gradient_background.dart';

class HomePageIndividual extends StatefulWidget {
  static const String routeName = '/HomePageIndividual';
  const HomePageIndividual({Key? key}) : super(key: key);

  @override
  State<HomePageIndividual> createState() => _HomePageIndividualState();
}

class _HomePageIndividualState extends State<HomePageIndividual> {
  @override
  void initState() {
    super.initState();
    _loadMediaData();
    _loadUnreadNotifications();
    _loadUnreadRequests();
  }

  List<String> mediaUrls = [];
  List<String> headings = [];
  List<String> subHeadings = [];
  List<String> img = [];
  int notificationCount = 0;
  Future<void> _loadUnreadRequests() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      if (!ip.startsWith('http://') && !ip.startsWith('https://')) {
        ip = 'http://$ip';
      }
      String unreadRequestsUrl = "$ip/api/unread_requests";

      var response = await http.post(Uri.parse(unreadRequestsUrl), body: {'lid': lid});
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        String status = jsonData['status'].toString();

        if (status == "true") {
          setState(() {
            unreadRequestCount = int.parse(jsonData['count'].toString());
          });
        } else {
          print("Failed to fetch unread requests.");
        }
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching unread requests: $e");
    }
  }

  Future<void> _loadMediaData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      if (!ip.startsWith('http://') && !ip.startsWith('https://')) {
        ip = 'http://$ip';
      }
      print("IP Address: $ip");
      String categoryUrl = "$ip/api/view_class_video";

      var data = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        String status = jsonData['status'].toString();

        if (status == "true" && jsonData['data'] != null) {
          List<dynamic> dataList = jsonData['data'];
          setState(() {
            mediaUrls = dataList.map((item) => item['file_path'].toString()).toList();
            print(mediaUrls);
            img = mediaUrls.map((url) {
              String fullUrl = '$ip/${Uri.encodeComponent(url)}';
              return fullUrl;
            }).toList();
            print(img);
            headings = dataList.map((item) => item['vname'].toString()).toList();
            subHeadings = dataList.map((item) => item['title'].toString()).toList();
          });
        } else {
          print("API returned an error status or no data.");
        }
      } else {
        print("Failed to fetch data. Status code: ${data.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }
  Future<void> _resetNotificationCount() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      if (!ip.startsWith('http://') && !ip.startsWith('https://')) {
        ip = 'http://$ip';
      }
      String resetNotificationUrl = "$ip/api/reset_notifications";

      var response = await http.post(Uri.parse(resetNotificationUrl), body: {'lid': lid});
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        String status = jsonData['status'].toString();

        if (status == "true") {
          setState(() {
            notificationCount = 0;
          });
        } else {
          print("Failed to reset notifications.");
        }
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error resetting notifications: $e");
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
  Future<String> _getProfilePhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ipAddress = prefs.getString("url") ?? ""; // Get the base URL
    String profilePhotoPath = prefs.getString('vimage') ?? ''; // Get the profile photo path
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
            notificationCount = 0;
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


  int _currentIndex = 0;
  int unreadRequestCount = 0;
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, HomePageIndividual.routeName);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SendAppointment(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewApp(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => reward(),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => reward(),
          ),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => request(),
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => IntroScreen(),
      ),
    );
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
                      icon: Icon(Icons.video_call),
                      onPressed: () async {
                        await _markNotificationsAsRead(); // Mark notifications as read
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DemoVideo(), // Replace with your actual widget
                          ),
                        );
                      },
                    ),

                  ],
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(Icons.request_page),
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => request(), // Replace with your actual widget
                          ),
                        );
                      },
                    ),
                    if (unreadRequestCount > 0)
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
                              '$unreadRequestCount',
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
                            builder: (context) => OrgChatScreen(), // Replace with your actual widget
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
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: _logout,
                  ); // Fallback to logout icon if there is an error or no data
                } else {
                  return PopupMenuButton<String>(
                    icon: CircleAvatar(
                      backgroundImage: NetworkImage(snapshot.data!),
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
                              builder: (context) => VProUpdate(), // Replace with your actual widget
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



        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFE3BD8D),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'Appointment',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review),
              label: 'Review',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: 'Rewards',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.request_page),
            //   label: 'Requests',
            // ),
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
                    image: const AssetImage("assets/care.png"),
                    height: 300.h,
                    width: double.infinity,
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: img.length,
                      itemBuilder: (context, index) {
                        bool isVideo = img[index].toLowerCase().contains('.mp4');
                        return HomePageContent(
                          mediaUrl: img[index],
                          heading: headings[index],
                          subHeading: subHeadings[index],
                          isVideo: isVideo,
                          heroTag: 'media$index',
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


class HomePageContent extends StatelessWidget {
  final String mediaUrl, heading, subHeading;
  final bool isVideo;
  final String heroTag;

  const HomePageContent({
    Key? key,
    required this.mediaUrl,
    required this.heading,
    required this.subHeading,
    required this.isVideo,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isVideo) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenVideoPlayer(videoUrl: mediaUrl),
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Hero(
          tag: heroTag,
          child: Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: const [
                BoxShadow(blurRadius: 5, color: Colors.grey, offset: Offset(2, 3)),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: TextPart(heading: heading, subHeading: subHeading),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 4,
                    child: isVideo
                        ? VideoPart(videoUrl: mediaUrl)
                        : ImagePart(imgUrl: mediaUrl),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImagePart extends StatelessWidget {
  const ImagePart({
    Key? key,
    required this.imgUrl,
  }) : super(key: key);

  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0E4D7),
        borderRadius: BorderRadius.circular(25.r),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(imgUrl),
        ),
      ),
    );
  }
}

class VideoPart extends StatelessWidget {
  const VideoPart({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    // Calculate one-third the screen height
    double thirdScreenHeight = MediaQuery.of(context).size.height / 3;

    return Container(
      height: thirdScreenHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFC7E2E4),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Video Player'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                VideoProgressIndicator(_controller, allowScrubbing: true),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        });
                      },
                    ),
                    Text(
                      '${_controller.value.position.inMinutes}:${_controller.value.position.inSeconds.remainder(60)} / ${_controller.value.duration.inMinutes}:${_controller.value.duration.inSeconds.remainder(60)}',
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class TextPart extends StatelessWidget {
  const TextPart({
    Key? key,
    required this.heading,
    required this.subHeading,
  }) : super(key: key);

  final String heading, subHeading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          heading,
          style: TextStyle(
            fontSize: 25.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        Text(
          subHeading,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}