import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'do_viewfoodrequest.dart';

class FoodRequestPage extends StatefulWidget {
  const FoodRequestPage({Key? key}) : super(key: key);

  @override
  _FoodRequestPageState createState() => _FoodRequestPageState();
}

class _FoodRequestPageState extends State<FoodRequestPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  String _selectedMealTime = '';
  Map<String, bool> _isMealTimeBooked = {
    'Day': false,
    'Afternoon': false,
    'Evening': false,
    'Dinner': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Request'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFC7E2E4), // Skin color background
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (selectedDay.isAfter(DateTime.now().subtract(Duration(days: 1)))) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  _showMealTimeDialog(context); // Show popup on date selection
                }
              },
              enabledDayPredicate: (date) {
                return date.isAfter(DateTime.now().subtract(Duration(days: 1)));
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                if (_selectedMealTime.isNotEmpty) {
                  await _submitFoodRequest(); // Only submit the food request on button click
                } else {
                  _showMessage('Please select a meal time first.');
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => do_viewfoodrequest(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFC7E2E4),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // Function to check if the selected day is already booked for a specific meal time
  Future<bool> _checkIfDayIsBooked(String selectedMealTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String lid = prefs.getString("lid") ?? "";
    String url = '$ip/api/check_the_food_request';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'lid': lid,
          'day': selectedMealTime,
          'date': DateFormat('yyyy-MM-dd').format(_selectedDay),
        },
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseBody['status'] == 'already_booked') {
          return true; // Indicate that the day is booked
        }
      } else {
        print('Failed to check booking status. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error checking booking status: $error');
    }
    return false; // Indicate that the day is not booked
  }

  // Function to handle food request submission
  Future<void> _submitFoodRequest() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("url") ?? "";
      String lid = prefs.getString("lid") ?? "";
      String url = '$ip/api/food_donation';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'lid': lid,
          'day': _selectedMealTime,
          'date': DateFormat('yyyy-MM-dd').format(_selectedDay),
        },
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseBody['status'] == 'already_booked') {
          _showMessage('This day and meal time are already booked.');
        } else {
          _showMessage('Food request submitted successfully.');
        }
      } else {
        _showMessage('Failed to submit food request. Please try again.');
        print('Failed to submit food request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _showMessage('Error submitting food request: $error');
      print('Error submitting food request: $error');
    }
  }

  // Function to display a message
  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to display the meal time dialog with buttons
  void _showMealTimeDialog(BuildContext context) async {
    // Reset the booking status map
    _isMealTimeBooked = {
      'Day': false,
      'Afternoon': false,
      'Evening': false,
      'Dinner': false,
    };

    // Check if any meal times are already booked
    for (String mealTime in _isMealTimeBooked.keys) {
      _isMealTimeBooked[mealTime] = await _checkIfDayIsBooked(mealTime);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Meal Time'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 19.0,
                  runSpacing: 15.0,
                  children: <String>['Day', 'Afternoon', 'Evening', 'Dinner']
                      .map((String value) {
                    bool isBooked = _isMealTimeBooked[value] ?? false; // Ensure non-nullable check
                    return SizedBox(
                      width: 160.0,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: isBooked
                            ? null // Disable the button if already booked
                            : () {
                          setState(() {
                            _selectedMealTime = value; // Update the selected meal time
                          });
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(130, 50),
                          textStyle: TextStyle(fontSize: 12),
                          backgroundColor: isBooked ? Colors.grey : Colors.blue, // Gray out the button if booked
                        ),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(width: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/food1.png',
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
