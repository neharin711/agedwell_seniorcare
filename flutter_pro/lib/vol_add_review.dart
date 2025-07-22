import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pro/vol_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(ReviewApp());
}

class ReviewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rating and Reviews',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: RatingReviewsPage(),
    );
  }
}

class RatingReviewsPage extends StatefulWidget {
  @override
  _RatingReviewsPageState createState() => _RatingReviewsPageState();
}

class _RatingReviewsPageState extends State<RatingReviewsPage> {
  double averageRating = 0.0;
  int ratingCount = 0;
  List<Map<String, dynamic>> ratingData = [];
  List<Map<String, dynamic>> ratingData1 = [];

  @override
  void initState() {
    super.initState();
    fetchavgReviews();
    fetchReviews(); // Fetch reviews initially
  }

  Future<void> fetchavgReviews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String lid = prefs.getString("lid") ?? "";
    String url = "$ip/api/view_avg_review"; // Replace with your actual endpoint

    try {
      final response = await http.post(Uri.parse(url), body: {'login_id': lid});
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print("Response data: $jsonData");

        if (mounted) {
          setState(() {
            averageRating = (jsonData['data']['average_rate'] as num?)?.toDouble() ?? 0.0;
            ratingCount = jsonData['data']['rating_count'] ?? 0;
            ratingData1 = [
              {'starCount': 5, 'reviewCount': jsonData['data']['5_star_count'] ?? 0},
              {'starCount': 4, 'reviewCount': jsonData['data']['4_star_count'] ?? 0},
              {'starCount': 3, 'reviewCount': jsonData['data']['3_star_count'] ?? 0},
              {'starCount': 2, 'reviewCount': jsonData['data']['2_star_count'] ?? 0},
              {'starCount': 1, 'reviewCount': jsonData['data']['1_star_count'] ?? 0},
            ];
          });
        }
      } else {
        print('Failed to fetch reviews. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching reviews: $error');
    }
  }

  Future<void> fetchReviews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String lid = prefs.getString("lid") ?? "";
    String url = "$ip/api/view_review"; // Replace with your actual endpoint

    try {
      final response = await http.post(Uri.parse(url), body: {'login_id': lid});
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          ratingData = List<Map<String, dynamic>>.from(jsonData['data']);
          print("Fetched reviews: $ratingData");
        });
      } else {
        print('Failed to fetch reviews. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching reviews: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePageIndividual(),
              ),
            );
          },
        ),
        title: Text('Rating & Reviews'),
      ),
        body:  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RatingSummary(
              averageRating: averageRating,
              ratingCount: ratingCount,
              ratingData: ratingData1,
            ), // Pass ratingData1
            SizedBox(height: 20),
            Expanded(child: ReviewsList(reviews: ratingData)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WriteReviewPage()),
          ).then((_) {
            // Refresh reviews after returning from WriteReviewPage
            fetchavgReviews();
            fetchReviews();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int ratingCount;
  final List<Map<String, dynamic>> ratingData;

  RatingSummary({
    required this.averageRating,
    required this.ratingCount,
    required this.ratingData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          averageRating.toStringAsFixed(1),
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < averageRating.round() ? Icons.star : Icons.star_border,
              color:  Color.fromRGBO(20, 94, 23, 1.0),
            );
          }),
        ),
        SizedBox(height: 10),
        Text(
          '$ratingCount ratings',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 10),
        RatingDistribution(ratings: ratingData), // Pass the fetched data here
      ],
    );
  }
}

class RatingDistribution extends StatelessWidget {
  final List<Map<String, dynamic>> ratings;

  RatingDistribution({required this.ratings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ratings.map((rating) {
        int starCount = rating['starCount'];
        int reviewCount = int.tryParse(rating['reviewCount'].toString()) ?? 0; // Ensure it's treated as int

        return RatingBar(starCount: starCount, reviewCount: reviewCount);
      }).toList(),
    );
  }
}



class RatingBar extends StatelessWidget {
  final int starCount;
  final int reviewCount;

  RatingBar({required this.starCount, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$starCount stars'),
        SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: reviewCount / 100, // Assuming 100 is the maximum review count for simplicity
            backgroundColor: Colors.grey[300],
            color:  Color.fromRGBO(20, 94, 23, 1.0),
          ),
        ),
        SizedBox(width: 8),
        Text('$reviewCount reviews'),
      ],
    );
  }
}

class ReviewsList extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;

  ReviewsList({required this.reviews});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        int rating = int.tryParse(review['rate'].toString()) ?? 0; // Convert to int safely

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review['vname'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < rating ? Icons.star : Icons.star_border,
                          color:  Color.fromRGBO(20, 94, 23, 1.0),
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  review['review'],
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 5),
                Text(
                  review['date'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WriteReviewPage extends StatefulWidget {
  @override
  _WriteReviewPageState createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  int _rating = 0;
  final TextEditingController _controller = TextEditingController();

  Future<void> sendReviewAndLoginId(String reviewText, String loginId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("url") ?? "";
    String url = "$ip/api/send_review"; // Replace with your actual Python backend URL

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'review': reviewText, 'login_id': loginId, 'rate': _rating.toString()},
      );

      if (response.statusCode == 200) {
        print('Data sent successfully');
      } else {
        print('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What is your rate?'),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color:  Color.fromRGBO(20, 94, 23, 1.0),
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Please share your experience....',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String loginId = prefs.getString('lid') ?? '';
                String reviewText = _controller.text;

                // Perform the necessary actions with the review text and login_id
                print('Review submitted: $reviewText');
                print('Login ID: $loginId');

                // Send the data to the Python backend
                await sendReviewAndLoginId(reviewText, loginId);

                // Navigate back to the reviews list and refresh it
                Navigator.pop(context);
                // The following line refreshes the parent widget's state to update the reviews list
                (context as Element).reassemble();
              },
              child: Text('SEND REVIEW',
                style: TextStyle(
                color: Colors.white, // Set text color here
              ),),

              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(1, 38, 4, 1.0),

                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
