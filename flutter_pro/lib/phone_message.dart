import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

import 'd_home.dart';
import 'login.dart';

class messageScreen extends StatefulWidget {
  final String phone;
  const messageScreen({Key? key, required this.phone}) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<messageScreen> {
  final Telephony telephony = Telephony.instance;
  TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sendSms(widget.phone); // Pass the phone number
  }

  final SmsSendStatusListener listener = (SendStatus status) {
    // Handle the status
    print(status);
  };

  void _sendSms(String phoneNumber) async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    print(permissionsGranted);  // Check if permissions are granted
    bool? canSendSms = await telephony.isSmsCapable;
    print(canSendSms); // Check if SMS is capable
    SimState simState = await telephony.simState;
    print(simState);  // Check SIM state

    // Generate a random 6-digit OTP
    // final random = Random();
    // final otp = (100000 + random.nextInt(900000)).toString(); // Generates a number between 100000 and 999999
    //
    // // Store OTP in SharedPreferences
    // final sh = await SharedPreferences.getInstance();
    // await sh.setString('otp', otp);

    // Send the SMS with the generated OTP
    telephony.sendSms(
      to: phoneNumber,
      message: "Dear, thank you for your generous donation. Together, we make a difference!\n\n- Aged Well Senior Care \nLajpat Nagar-II, New Delhi, India\nPhone : +91-11-35667538",
      statusListener: listener,
    );
  }

  void _verifyOtp() async {
    final sh = await SharedPreferences.getInstance();
    String? storedOtp = sh.getString('otp');

    if (storedOtp == otpController.text) {
      // OTP is correct, proceed with registration completion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message successfully. Registration complete.'),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => d_home(),
          ),
        );
      });
    } else {
      // OTP is incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect OTP. Please try again.'),
        ),
      );
    }
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
              'ThankYou!!!!!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

          ],
        ),
      ),
    );
  }
}
