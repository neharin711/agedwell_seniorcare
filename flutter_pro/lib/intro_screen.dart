import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'main.dart';

void main() {
  runApp(AppPage());
}

class AppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: IntroScreen(),
      ),
    );
  }
}

class IntroScreen extends StatefulWidget {
  static const String routeName = '/IntroScreen';

  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final TextEditingController ipController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadIP();
  }

  Future<void> _loadIP() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedIP = prefs.getString("url");
    if (savedIP != null) {
      ipController.text = savedIP.replaceFirst("http://", "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.black,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/ippage.jpg"),
               alignment: Alignment.topCenter

               // Change this to BoxFit.contain if needed
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 20),
                      SizedBox(
                        height: 100.h,
                        width: 230.w,
                        child: Stack(
                          children: <Widget>[
                            Center(),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(height: 420.h),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: ipController,
                              decoration: InputDecoration(
                                labelText: "Enter Your IP...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              style: TextStyle(
                                     color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter the IP';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20.h),
                            IntroRoutingComponent(
                              icon: Icons.key,
                              text: "GET IP",
                              isEmail: true,
                              onTap: () async {
                                if (!_formKey.currentState!.validate()) {
                                  print("Not validated");
                                } else {
                                  String ip = ipController.text.toString();
                                  final sh = await SharedPreferences.getInstance();
                                  sh.setString("url", "http://$ip");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyApp()),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        child: SizedBox(
                          width: 500.w,
                          height: 50.h,
                          child: Center(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroRoutingComponent extends StatelessWidget {
  final IconData? icon;
  final String text;
  final void Function()? onTap;
  final bool isEmail;

  final primaryColor = const Color(0xFF92B7C0);

  const IntroRoutingComponent({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
    required this.isEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: isEmail ? primaryColor : Colors.white,
          border: isEmail ? null : Border.all(color: primaryColor, width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 30.w,
              color: isEmail ? Colors.white : primaryColor,
            ),
            SizedBox(width: 20.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: isEmail ? Colors.white : primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
