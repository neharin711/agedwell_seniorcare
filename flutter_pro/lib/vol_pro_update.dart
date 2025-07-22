import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import '../shared/widgets/gradient_background.dart';

class VProUpdate extends StatefulWidget {
  static const String routeName = '/IndividualAccountUpdate';
  const VProUpdate({Key? key}) : super(key: key);

  @override
  State<VProUpdate> createState() => _VProUpdateState();
}

class _VProUpdateState extends State<VProUpdate> {
  late List<TextEditingController> controllerList;

  final _indFormKey = GlobalKey<FormState>();

  final buttonStyle = TextButton.styleFrom(
    backgroundColor: const Color.fromARGB(100, 117, 212, 227),
  );

  final List<String> gender = ['Male', 'Female', 'Other'];
  String? userGender, dob, imgUrl;
  File? userImage;
  bool isSelected = false;
  File? userDocument;
  List<Map<String, dynamic>> messageData = [];

  @override
  void initState() {
    controllerList = List.generate(8, (index) => TextEditingController(), growable: false);
    _loadUserData(); // Load existing user data
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    for (var element in controllerList) {
      element.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("url") ?? "";
      String categoryUrl = '$ip/api/view_vol';

      var data = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      var jsonData = json.decode(data.body);
      String status = jsonData['status'].toString();

      if (status == "true") {
        setState(() {
          messageData = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);

          if (messageData.isNotEmpty) {
            var userData = messageData[0];
            controllerList[0].text = userData['vname'] ?? '';
            controllerList[1].text = userData['email'] ?? '';
            controllerList[2].text = userData['phone'] ?? '';
            controllerList[3].text = userData['occupation'] ?? '';
            controllerList[4].text = userData['dateofbirth'] ?? '';
            controllerList[5].text = userData['city'] ?? '';
            controllerList[6].text = userData['username'] ?? '';
            controllerList[7].text = userData['password'] ?? '';
            userGender = userData['gender'];
            dob = userData['dateofbirth'];
            imgUrl = '$ip/${userData['p_image']}';
          }
        });
      } else {
        // Handle error status if needed
      }
    } catch (e) {
      print("Error: $e");
      // Handle any errors that occur during the HTTP request.
    }
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      controllerList[0].text = prefs.getString('name') ?? '';
      controllerList[1].text = prefs.getString('email') ?? '';
      controllerList[2].text = prefs.getString('phone') ?? '';
      controllerList[3].text = prefs.getString('occupation') ?? '';
      controllerList[5].text = prefs.getString('city') ?? '';
      controllerList[6].text = prefs.getString('username') ?? '';
      controllerList[7].text = prefs.getString('password') ?? '';
      userGender = prefs.getString('gender');
      dob = prefs.getString('dob');
      imgUrl = prefs.getString('img');
    });
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
                          iconSize: 20.h,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Profile Update",
                          style: TextStyle(
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: userImage != null
                            ? FileImage(userImage!) as ImageProvider
                            : (imgUrl != null
                            ? NetworkImage(imgUrl!)
                            : const AssetImage('assets/startup_assets/create_account_assets/profile_primary.png')
                        ) as ImageProvider,
                        radius: 50.r,
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
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
                          // Handle image upload logic
                          _submitForm(context);
                        },
                        style: buttonStyle,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            onPressed: () => pickImage(ImageSource.camera),
                            icon: Icon(
                              Icons.camera_alt_outlined,
                              size: 30.h,
                            ),
                          ),
                          SizedBox(width: 20.w),
                          IconButton(
                            onPressed: () => pickImage(ImageSource.gallery),
                            icon: Icon(
                              Icons.photo,
                              size: 30.h,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Form(
                        key: _indFormKey,
                        child: ListView(
                          children: <Widget>[
                            buildTextField("Name", controllerList[0]),
                            SizedBox(height: 10.h),
                            buildTextField("Email", controllerList[1], keyboardType: TextInputType.emailAddress),
                            SizedBox(height: 10.h),
                            buildTextField("Phone", controllerList[2], keyboardType: TextInputType.phone),
                            SizedBox(height: 10.h),
                            buildTextField("Occupation", controllerList[3]),
                            SizedBox(height: 10.h),
                            buildTextField("Date of Birth", controllerList[4], readOnly: true, onTap: () => _selectDate(context)),
                            SizedBox(height: 10.h),
                            buildTextField("City", controllerList[5]),
                            SizedBox(height: 10.h),
                            buildTextField("Username", controllerList[6]),
                            SizedBox(height: 10.h),
                            buildTextField("Password", controllerList[7], obscureText: true),
                            SizedBox(height: 10.h),
                            buildGenderDropdown(),
                            SizedBox(height: 20.h),
                            TextButton(
                              onPressed: () => _submitForm(context),
                              style: buttonStyle,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                                child: Text(
                                  "Update",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            buildUploadDocumentButton(),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        dob = "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
        controllerList[4].text = dob!;
      });
    }
  }

  Widget buildTextField(String labelText, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool readOnly = false, VoidCallback? onTap, bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 18.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }

  Widget buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: userGender,
      onChanged: (String? newValue) {
        setState(() {
          userGender = newValue;
        });
      },
      items: gender.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: TextStyle(fontSize: 18.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      validator: (value) => value == null ? 'Please select gender' : null,
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        userImage = File(pickedFile.path);
        isSelected = true;
      });
    } else {
      print('No image selected.');
    }
  }

  Widget buildUploadDocumentButton() {
    return TextButton(
      onPressed: () => _uploadDocument(context),
      style: buttonStyle,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: Text(
          "Upload Document",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Future<void> _uploadDocument(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        userDocument = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Document selected: ${pickedFile.path}"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No document selected"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_indFormKey.currentState!.validate()) {
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String lid = prefs.getString('lid') ?? '';
    String url = prefs.getString('url') ?? '';
    String updateUrl = '$url/api/vol_update';

    final request = http.MultipartRequest('POST', Uri.parse(updateUrl));

    request.fields['lid'] = lid;
    request.fields['vname'] = controllerList[0].text;
    request.fields['email'] = controllerList[1].text;
    request.fields['phone'] = controllerList[2].text;
    request.fields['occupation'] = controllerList[3].text;
    request.fields['dateofbirth'] = controllerList[4].text;
    request.fields['city'] = controllerList[5].text;
    request.fields['username'] = controllerList[6].text;
    request.fields['password'] = controllerList[7].text;
    request.fields['gender'] = userGender ?? '';

    if (userImage != null) {
      request.files.add(await http.MultipartFile.fromPath('p_image', userImage!.path));
    }

    if (userDocument != null) {
      request.files.add(await http.MultipartFile.fromPath('file_upload', userDocument!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      final status = jsonResponse['status'];

      if (status == 'true') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
