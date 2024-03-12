import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:looksbeyondclient/models/logged_in_brand.dart';
import 'package:looksbeyondclient/models/brand_booking.dart';
import 'package:looksbeyondclient/provider/AuthProvider.dart';
import 'package:provider/provider.dart';

class FeedbackPage extends StatefulWidget {
  static const String pageName = '/feedback';


  const FeedbackPage({
    Key? key,

  }) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late AuthenticationProvider authenticationProvider;
  double _rating = 0.0;
  TextEditingController _commentController = TextEditingController();
  late BrandBooking booking;
  bool isReviewExist = false;
  late LoggedInBrand loggedInUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  booking = ModalRoute.of(context)!.settings.arguments as BrandBooking;
  authenticationProvider = Provider.of<AuthenticationProvider>(context, listen: false);
  loggedInUser = authenticationProvider.loggedInBrand!;
  checkReviewExistence();
    return Scaffold(
      appBar: AppBar(
        title: Text(isReviewExist?"Edit Feedback":'Provide Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service: ${booking.title}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text(
              'Stylist: ${booking.employee}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text(
              'Brand: ${booking.brand}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            Text(
              'Rating:',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Slider(
              value: _rating,
              onChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating.toStringAsFixed(1),
            ),
            SizedBox(height: 20.0),
            Text(
              'Feedback:',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your feedback...',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _submitFeedback();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void checkReviewExistence() async {
    // Check if a review already exists for the current booking
    QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('bookingId', isEqualTo: booking.id)
        .limit(1)
        .get();

    setState(() {
      isReviewExist = reviewSnapshot.docs.isNotEmpty;
    });

    if (isReviewExist) {
      // If a review exists, populate the feedback fields with existing review data
      DocumentSnapshot reviewDoc = reviewSnapshot.docs.first;
      double existingRating = reviewDoc['rating'];
      String existingComment = reviewDoc['comment'];

      setState(() {
        _rating = existingRating;
        _commentController.text = existingComment;
      });
    }
  }

  void _submitFeedback() {
    // Submit feedback logic
    double rating = _rating;
    String comment = _commentController.text;

    FirebaseFirestore.instance.collection('reviews').add({
      'userName': loggedInUser.brand,
      'bookingId': booking.id,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.now(),
      'empId': booking.employee,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'brandId': booking.brand,
    });

    // After submitting, you can navigate back to the previous screen.
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
