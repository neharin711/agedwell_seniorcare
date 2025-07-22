import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pro/shared/widgets/gradient_background.dart';

class OrgChatScreen extends StatefulWidget {
  static const String routeName = '/OrgChatScreen';

  @override
  State<OrgChatScreen> createState() => _OrgChatScreenState();
}

class _OrgChatScreenState extends State<OrgChatScreen> {
  final TextEditingController messageController = TextEditingController();
  List<Message> messages = [];
  late String loginId;
  final List<String> months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadMessages();
    loadLoginId();
  }

  Future<void> loadMessages() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? ""; // Handle null safety
      String ip = pref.getString("url") ?? "";
      String categoryUrl = ip + "/api/view_chat_list";

      var data = await http.post(Uri.parse(categoryUrl), body: {
        'lid': lid,
      });

      var jsonData = json.decode(data.body);
      print("JSON Response: $jsonData");

      String status = jsonData['status'];
      if (status == "true") {
        setState(() {
          messages = List<Message>.from(jsonData['data'].map((message) => Message(
            senderId: message['sender_id'].toString(),
            messageContent: message['message'],
            date: message['date'],
            profileImage: message['p_image'],

          )));
        });
        print("Messages: $messages");
      } else {
        // Handle error status if needed
        print("Error: ${jsonData['message']}");
      }
    } catch (e, stackTrace) {
      print("Error: $e");
      print("Stack trace: $stackTrace");
    }
  }


  Future<void> loadLoginId() async {
    final pref = await SharedPreferences.getInstance();
    String? lid = pref.getString("lid"); // Handle null safety
    if (lid != null) {
      setState(() {
        loginId = lid;
      });
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String sendMessageUrl = ip + "/api/chat_with_admin";

      var response = await http.post(
        Uri.parse(sendMessageUrl),
        body: {
          'lid': lid,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        print('Message sent successfully');
        loadMessages();
      } else {
        print('Error sending message: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardActive = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ScreenUtilInit(
        designSize: const Size(428, 926),
        builder: (context, child) => Stack(
          children: [
            const UniDirectionalBackground(), // Replace with your gradient background widget
            SafeArea(
              child: Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.r),
                          topRight: Radius.circular(10.r),
                        ),
                      ),
                      child: FutureBuilder<String>(
                        future: _getIpAddress(), // Replace with your method to fetch IP address
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            String ipAddress = snapshot.data ?? "";
                            return ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                bool showDate = false;
                                String imageUrl = ipAddress + "/" + message.profileImage;
                                print(imageUrl);

                                DateTime messageDate = DateTime.parse(message.date); // Assuming 'message.date' is in a parsable format
                                if (index == 0 || !isSameDay(messageDate, DateTime.parse(messages[index - 1].date))) {
                                  showDate = true;
                                }

                                return Column(
                                  children: [
                                    if (showDate) DateMsgTile(convDate: "${messageDate.day} ${months[messageDate.month - 1]} ${messageDate.year}"),
                                    MessageWidget(
                                      isMe: message.senderId == loginId,
                                      msg: message.messageContent,

                                      showDate: false, // Set this to false to avoid duplicate date display
                                      nextDate: index < messages.length - 1 ? messages[index + 1].date : null,
                                      orgImgUrl: imageUrl,
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Center(
                    child: Container(
                      height: 80.h,
                      width: 400.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF92B7C0),
                        borderRadius: BorderRadius.circular(40.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              keyboardType: TextInputType.multiline,
                              minLines: null,
                              maxLines: null,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w300,
                              ),
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Type a message....",
                                hintStyle: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w300,
                                ),
                                contentPadding: EdgeInsets.only(left: 15), // Adjust left padding as needed
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final time = DateTime.now();
                              int hour = time.hour;
                              String meridian = hour < 12 ? "am" : "pm";
                              hour = hour % 12;
                              hour = hour == 0 ? 12 : hour;
                              String timeInHours = hour < 10 ? "0$hour" : hour.toString();
                              int minutes = time.minute;
                              String minute = minutes < 10 ? "0$minutes" : minutes.toString();
                              String month = months[time.month - 1];

                              String messageContent = messageController.text.trim();
                              if (messageContent.isNotEmpty) {
                                setState(() {
                                  messages.add(Message(
                                    senderId: loginId,
                                    messageContent: messageContent,
                                    date: "${time.day} $month ${time.year}",
                                    profileImage: "assets/startup_assets/create_account_assets/admin_logo.png",

                                  ));
                                });

                                messageController.clear();
                                FocusScope.of(context).unfocus();

                                await sendMessage(messageContent);
                              } else {
                                print('Message cannot be empty');
                              }
                            },
                            iconSize: 28.h,
                            icon: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  if (isKeyboardActive)
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom,
                    ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                      iconSize: 22.h,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 30.w,
                      child: Image(
                        image: AssetImage("assets/startup_assets/create_account_assets/profile_primary.png"),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Text(
                      "Admin",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final String senderId;
  final String messageContent;
  final String date;
  final String profileImage;


  Message({
    required this.senderId,
    required this.messageContent,
    required this.date,
    required this.profileImage,

  });
}

class DateMsgTile extends StatelessWidget {
  final String convDate;

  const DateMsgTile({
    Key? key,
    required this.convDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 118.w,
            height: 25.h,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(130, 113, 228, 0.5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                convDate,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final bool isMe, showDate;
  final String msg, orgImgUrl;
  final String? nextDate;

  const MessageWidget({
    Key? key,
    required this.isMe,
    required this.msg,
    required this.showDate,
    this.nextDate,
    required this.orgImgUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dpUrl = isMe ? orgImgUrl : "assets/startup_assets/create_account_assets/admin_logo.png";
    const BorderRadius myBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
    );
    const BorderRadius senderBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomRight: Radius.circular(20),
    );

    final List<Widget> rowItems = <Widget>[
      CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 15, // You can adjust the radius as needed
        backgroundImage: isMe ? NetworkImage(dpUrl) : AssetImage(dpUrl) as ImageProvider,
      ),
      SizedBox(width: 10),
      Container(
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE0EEEF) : const Color(0xFFD9D9D9),
          borderRadius: isMe ? myBorderRadius : senderBorderRadius,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Text(
            msg,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    ];

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: isMe ? rowItems.reversed.toList() : rowItems,
        ),
        const SizedBox(height: 20),
        if (showDate) DateMsgTile(convDate: nextDate!),
      ],
    );
  }
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
}


Future<String> _getIpAddress() async {
  final sh = await SharedPreferences.getInstance();
  return sh.getString("url") ?? "";

}
