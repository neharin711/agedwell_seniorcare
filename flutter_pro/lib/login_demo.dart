import 'package:flutter/material.dart';
import 'package:flutter_pro/vol_home.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import 'package:http/http.dart' as http; // Import for HTTP requests
import 'dart:convert';

import 'd_home.dart'; // Import for JSON decoding

void main() {
  runApp(LoginDemo());
}

class LoginDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  final Color _primaryColor = const Color(0xFF729CA3);

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
        } else if (status == "donor") {
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
        } else {
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Spacer(),
                Image.asset(
                  'assets/login2.png', // Add your image asset here
                  height: 200.0,
                ),
                SizedBox(height: 40),
                Text(
                  "Welcome Back",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Please, Log In.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.email, color: Colors.grey),
                          hintText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        obscureText: _obscureText,
                        controller: passwordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.lock, color: Colors.grey),
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
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
                    ],
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text('Login', style: TextStyle(fontSize: 18,color: Colors.white)),
                ),
                SizedBox(height: 20),
                // Text(
                //   "Or",
                //   textAlign: TextAlign.center,
                //   style: TextStyle(color: Colors.white70, fontSize: 16),
                // ),
                SizedBox(height: 10),
                // TextButton(
                //   onPressed: () {},
                //   style: TextButton.styleFrom(
                //     padding: EdgeInsets.symmetric(vertical: 16.0),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(30.0),
                //       side: BorderSide(color: Colors.white),
                //     ),
                //   ),
                //   child: Text(
                //     'Create an Account',
                //     style: TextStyle(color: Colors.white, fontSize: 18),
                //   ),
                // ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
