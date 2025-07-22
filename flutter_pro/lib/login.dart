import 'package:flutter/material.dart';
import 'package:flutter_pro/vol_home.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


import 'd_home.dart';
class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);

  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color _primaryColor = const Color(0xFF729CA3);
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      print("Not validated");
    } else {
      final SharedPreferences sh = await SharedPreferences.getInstance();
      String username = usernameController.text.toString();
      String password = passwordController.text.toString();
      String url = sh.getString("url") ?? "";

      try {
        var response = await http.post(
          Uri.parse("$url/api/login"),
          body: {
            'username1': username,
            'password': password,
          },
        );
        print(response);
        var jsonData = json.decode(response.body);
        String status = jsonData['type'].toString();

        if (status == "volunteer") {
          String lid = jsonData['lid'].toString();
          sh.setString("lid", lid);
          String image = jsonData['img'].toString();
          sh.setString("vimage", image);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePageIndividual()), // Replace with your home page widget
          );
        }
        else if (status == "donor") {
          String lid = jsonData['lid'].toString();
          sh.setString("lid", lid);
          String dphone = jsonData['phone'].toString();
          sh.setString("dphone", dphone);
          print("dphone $dphone");
          String image = jsonData['img'].toString();
          sh.setString("pimage", image);
          print("dphone $dphone");
          print("Image $image");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => d_home()), // Replace with your home page widget
          );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid username or password.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      builder: (context, child) => Scaffold(
        body: Stack(
          children: [
            // Background image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/rr.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 10, color: Colors.white12),
                      right: BorderSide(width: 10, color: Colors.white12),
                      top: BorderSide(width: 10, color: Colors.white12),
                      bottom: BorderSide(width: 10, color: Colors.white12),

                    ),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(40.r),
                    // border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40.h),
                        // Username field
                        Container(

                          child: TextFormField(
                            controller: usernameController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Username",
                              hintText: "Enter your username",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20.h),
                        // Password field
                        Container(

                          child: TextFormField(
                            controller: passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "Enter your password",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20.h),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            "LOG IN",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        _toggleLoginSignupText(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleLoginSignupText() {
    return Column(
      children: [],
    );
  }
}
