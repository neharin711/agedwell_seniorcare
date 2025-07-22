// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_pro/vol_com_work.dart';
// import 'package:flutter_pro/vol_home.dart';
// import 'package:flutter_pro/vol_pickup.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:lottie/lottie.dart';
//
//
// void main() {
//   runApp(vol_view_req());
// }
//
// class vol_view_req extends StatelessWidget {
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Requirements',
//       theme: ThemeData(
//         primarySwatch: Colors.orange,
//       ),
//       home: VolViewReqPage(d_cat_id: '',),
//     );
//   }
// }
//
//
// class VolViewReqPage extends StatefulWidget {
//   final String d_cat_id; // Declare this variable
//
//   VolViewReqPage({required this.d_cat_id});
//
//   @override
//   _VolViewReqPageState createState() => _VolViewReqPageState();
// }
//
//
//
// class _VolViewReqPageState extends State<VolViewReqPage> {
//   List<Map<String, dynamic>> messageData = [];
//   List<bool> isSelected = [true, false, false];
//   @override
//   void initState() {
//     super.initState();
//     _loadMessages();
//   }
//
//   Future<void> _loadMessages() async {
//     try {
//       final pref = await SharedPreferences.getInstance();
//       String lid = pref.getString("lid") ?? "";
//       String ip = pref.getString("url") ?? "";
//       String categoryUrl = ip + "/api/view_vol_req";
//
//       var data = await http.post(Uri.parse(categoryUrl), body: {'lid': lid,'id':widget.d_cat_id});
//       var jsonData = json.decode(data.body);
//       String status = jsonData['status'].toString();
//
//       if (status == "true") {
//         setState(() {
//           messageData = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
//         });
//       } else {
//         // Handle error status if needed
//         print("API returned error status.");
//       }
//     } catch (e) {
//       print("Error: $e");
//       // Handle any errors that occur during the HTTP request.
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: BackButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HomePageIndividual(),
//               ),
//             );
//           },
//         ),
//
//         title: Text('Requirements'),
//       ),
//       body: Column(
//         children: [
//
//           Expanded(
//             child: ListView.builder(
//               itemCount: messageData.length,
//               itemBuilder: (context, index) {
//                 return JobCardrequest(
//                   item: "Requirements: ${messageData[index]['request'] ?? 'Item Not Available'}",
//                   dname: "Date: ${messageData[index]['date'] ?? 'Name Not Available'}",
//                   status: messageData[index]['status'] ?? "Status Not Available",
//                   onTap: () {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return DonationPopup(
//                           item: " ${messageData[index]['request'] ?? 'Item Not Available'}",
//                           date: " ${messageData[index]['date'] ?? 'Date Not Available'}",
//                           item_id: " ${messageData[index]['d_req_id'] ?? 'Item Not Available'}",
//                         );
//                       },
//                     );
//                   },
//
//                 );
//               },
//             ),
//           )
//
//         ],
//       ),
//     );
//   }
// }
//
//
// class DonationPopup extends StatefulWidget {
//   final String item;
//   final String date;
//   final String item_id;
//
//   DonationPopup({required this.item, required this.date,required this.item_id});
//
//   @override
//   _DonationPopupState createState() => _DonationPopupState();
// }
//
// class _DonationPopupState extends State<DonationPopup> {
//   String _selectedOption = 'Drop'; // Default to Drop
//   final TextEditingController _addressController = TextEditingController();
//
//   @override
//   void dispose() {
//     _addressController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _submitDonation() async {
//     try {
//       // Define your API endpoint
//
//       String ip = await _getIpAddress();
//       String apiUrl = ip + "/api/add_vol_req"; //
//       final pref = await SharedPreferences.getInstance();
//       String lid = pref.getString("lid") ?? "";
//
//       // Prepare the data to send
//       Map<String, String> donationData = {
//         'item': widget.item,
//         'lid': lid,
//         'item_id': widget.item_id,
//         'date': widget.date,
//         'option': _selectedOption,
//       };
//
//       if (_selectedOption == 'Pickup' && _addressController.text.isNotEmpty) {
//         donationData['address'] = _addressController.text;
//       } else {
//         donationData['address'] = '';
//       }
//
//       // Make the HTTP POST request
//       var response = await http.post(
//         Uri.parse(apiUrl),
//         body: donationData,
//       );
//
//       // Handle response from the server
//       if (response.statusCode == 200) {
//         // Navigate to success page or show a success message
//         Navigator.of(context).pop(); // Close the dialog
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SuccessAnimationPage()),
//         );
//       } else {
//         // Show an error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to submit donation. Please try again.')),
//         );
//       }
//     } catch (e) {
//       // Handle network or other errors
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//
//   Future<String> _getIpAddress() async {
//     final sh = await SharedPreferences.getInstance();
//     return sh.getString("url") ?? "";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Are you ready to Accept this Appointment?'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//
//
//           // Show text field only if Pickup is selected
//
//         ],
//       ),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {
//
//               _submitDonation(); // Submit the donation details
//
//           },
//           child: Text('Submit'),
//         ),
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop(); // Close the dialog
//           },
//           child: Text('Cancel'),
//         ),
//       ],
//     );
//   }
// }
//
// class JobCardrequest extends StatelessWidget {
//   final String item;
//   final String dname;
//   final String status;
//   final VoidCallback onTap;
//
//   const JobCardrequest({
//     Key? key,
//     required this.item,
//     required this.dname,
//     required this.status,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(10.0),
//       child: ListTile(
//         title: Text(item),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(dname),
//             Text(status),
//           ],
//         ),
//
//         onTap: onTap,
//       ),
//     );
//   }
// }
//
//
//
// Future<String> _getIpAddress() async {
//   final sh = await SharedPreferences.getInstance();
//   return sh.getString("url") ?? "";
// }
//
//
// class SuccessAnimationPage extends StatefulWidget {
//   @override
//   _SuccessAnimationPageState createState() => _SuccessAnimationPageState();
// }
//
// class _SuccessAnimationPageState extends State<SuccessAnimationPage> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration(seconds: 5), () {
//       Navigator.pop(context);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(''),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Lottie.asset(
//               'assets/animation2.json', // Ensure the path is correct
//               width: 300,
//               height: 300,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Request Accept Successful!',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
