import 'package:flutter/material.dart';
import 'package:flutter_pro/login.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart'; // Add this line
import 'package:http_parser/http_parser.dart'; // Add this line for MIME type

import '../shared/widgets/gradient_background.dart';

class IndividualAccountSetup extends StatefulWidget {
  static const String routeName = '/IndividualAccountSetup';
  const IndividualAccountSetup({Key? key}) : super(key: key);

  @override
  State<IndividualAccountSetup> createState() => _IndividualAccountSetupState();
}

class _IndividualAccountSetupState extends State<IndividualAccountSetup> {
  late List<TextEditingController> controllerList;

  final _indFormKey = GlobalKey<FormState>();

  final buttonStyle = TextButton.styleFrom(
    backgroundColor: const Color.fromARGB(100, 117, 212, 227),
  );

  final List<String> gender = ['Male', 'Female', 'Other'];
  String? userGender, dob, imgUrl, imgName = "random212";
  File? userImage;
  bool isSelected = false;
  File? userDocument; // New variable for uploaded document

  @override
  void initState() {
    controllerList = List.generate(8, (index) => TextEditingController(), growable: false);
    super.initState();
  }

  @override
  void dispose() {
    for (var element in controllerList) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      builder: (context, child) => Scaffold(
        body: Stack(
          children: <Widget>[
            const UniDirectionalBackground(),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          iconSize: 14.h,
                        ),
                        Text(
                          "Profile Setup",
                          style: TextStyle(
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: userImage == null
                            ? const AssetImage('assets/startup_assets/create_account_assets/profile_primary.png')
                            : FileImage(userImage!) as ImageProvider,
                        radius: 50.r,
                        backgroundColor: Colors.transparent,
                      ),
                      Column(
                        children: <Widget>[
                          TextButton(
                            onPressed: () async {
                              if (!isSelected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Select an image first"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              // Here you would handle uploading logic if needed
                              // imgUrl = await storage.postFile(userImage!, "DisplayPictures/${imgName!}");
                            },
                            style: buttonStyle,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                              child: Text(
                                "Upload Profile Picture",
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  try {
                                    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                    if (image == null) return;
                                    setState(() {
                                      userImage = File(image.path);
                                      imgName = image.name ?? "random212";
                                      isSelected = true;
                                    });
                                  } catch (e) {
                                    print("An error has occurred!");
                                  }
                                },
                                style: buttonStyle,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  child: Text(
                                    "From Gallery",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 25.w),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    final image = await ImagePicker().pickImage(source: ImageSource.camera);
                                    if (image == null) return;
                                    setState(() {
                                      userImage = File(image.path);
                                      isSelected = true;
                                      imgName = image.name ?? "random212";
                                    });
                                  } catch (e) {
                                    print("An error has occurred! ${e.toString()}");
                                  }
                                },
                                style: buttonStyle,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  child: Text(
                                    "Take Now",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Center(
                    child: Text(
                      "Enter Your Details:",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  const Divider(
                    thickness: 2,
                    color: Color.fromRGBO(0, 0, 0, 0.33),
                  ),
                  Expanded(
                    child: Form(
                      key: _indFormKey,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                        child: Column(
                          children: <Widget>[
                            getInputTextField(controllerList[0], "Enter your Name", TextInputType.name, (val) {
                              if (val == null || val.isEmpty) {
                                return "Please enter your name";
                              }
                              return null;
                            }),
                            SizedBox(
                              height: 34.h,
                            ),

                            getInputTextField(controllerList[1], "Enter your Email", TextInputType.emailAddress, (val) {
                              if (val == null || val.isEmpty || !val.contains('@')) {
                                return "Please enter a proper email address";
                              }
                              return null;
                            }),
                            SizedBox(
                              height: 34.h,
                            ),
                            getInputTextField(controllerList[2], "Enter your Phone Number", TextInputType.number,
                                    (val) {
                                  if (val == null || val.isEmpty) {
                                    return "Please enter your contact number";
                                  }
                                  return null;
                                }),
                            SizedBox(
                              height: 34.h,
                            ),
                            getInputTextField(controllerList[3], "Enter your Occupation", TextInputType.name, (val) {
                              if (val == null || val.isEmpty) {
                                return "Please enter your occupation";
                              }
                              return null;
                            }),
                            SizedBox(
                              height: 34.h,
                            ),
                            Row(
                              
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: 170.w,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(117, 212, 227, 0.2),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                        value: userGender,
                                        style: TextStyle(
                                            fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black),
                                        hint: Text("Gender",
                                            style: TextStyle(
                                                fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                                        items: gender.map((value) {
                                          return DropdownMenuItem(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            userGender = value!.toString();
                                          });
                                        }),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime(2012, 1),
                                        firstDate: DateTime(1940, 1),
                                        lastDate: DateTime(2012, 1));
                                    if (picked != null) {
                                      setState(() {
                                        dob = "${picked.day}/${picked.month}/${picked.year}";
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 60.h,
                                    width: 170.w,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(117, 212, 227, 0.2),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
                                    child: Text(
                                      dob == null ? "Select Date" : dob!,
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 34.h,
                            ),
                            getInputTextField(controllerList[5], "Enter your City", TextInputType.text, (val) {
                              if (val == null || val.isEmpty) {
                                return "Please enter your city";
                              }
                              return null;
                            }),
                            SizedBox(
                              height: 34.h,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Upload your ID/Document",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final picker = ImagePicker();
                                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                                    if (pickedFile != null) {
                                      setState(() {
                                        userDocument = File(pickedFile.path);
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 60.h,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(117, 212, 227, 0.2),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Center(
                                      child: Text(
                                        userDocument == null
                                            ? "Select Document"
                                            : "Document Selected: ${basename(userDocument!.path)}",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 34.h,
                            ),
                            getInputTextField(controllerList[6], "Enter your Username", TextInputType.text, (val) {
                              if (val == null || val.isEmpty) {
                                return "Please enter your Username";
                              }
                              return null;
                            }),
                            SizedBox( height: 34.h,
                            ),
                            getInputTextField(controllerList[7], "Enter your Password", TextInputType.text, (val) {
                              if (val == null || val.isEmpty) {
                                return "Please enter your Password";
                              }
                              return null;
                            }),
                            SizedBox( height: 34.h,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_indFormKey.currentState!.validate()) {
                                  await saveFormData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Data is saved")),
                                  );
                                }
                              },
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => UserLogin()), // Replace with your home page widget
                                  );
                                },
                                child: Text('Already a User? Log In'),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget getInputTextField(
      TextEditingController controller, String hintText, TextInputType keyboardType, FormFieldValidator<String> validator) {
    return Container(
      height: 60.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(117, 212, 227, 0.2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Future<void> saveFormData() async {
    final SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString("url").toString();

    // Extract values from text controllers
    String name = controllerList[0].text;
    String email = controllerList[1].text;
    String phone = controllerList[2].text;
    String occupation = controllerList[3].text;
    String city = controllerList[5].text;
    String username = controllerList[6].text;
    String password = controllerList[7].text;

    // Prepare the request body
    var request = http.MultipartRequest('POST', Uri.parse(url + "/api/vol_register"));

    // Add fields
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['phone'] = phone;
    request.fields['occupation'] = occupation;
    request.fields['city'] = city;
    request.fields['username'] = username;
    request.fields['password'] = password;
    request.fields['gender'] = userGender ?? '';
    request.fields['dob'] = dob ?? '';

    // Add image file
    if (userImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          userImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    // Add document file
    if (userDocument != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          userDocument!.path,
          contentType: MediaType('application', 'pdf'), // Assuming PDF document
        ),
      );
    }

    // Send request
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        // Handle success response
        var responseData = await http.Response.fromStream(response);
        var jsonData = json.decode(responseData.body);
        print("Data saved successfully");
        // Navigate to next screen or handle success scenario
      } else {
        // Handle other status codes
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending data: $e");
      // Handle error scenario
    }
  }

}
