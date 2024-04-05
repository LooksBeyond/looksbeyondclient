import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:looksbeyondclient/models/brand_booking.dart';

class BookingDetails extends StatefulWidget {
  static const String pageName = '/bookingDetails';
  const BookingDetails({super.key});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  @override
  Widget build(BuildContext context) {
    final brandBooking =
        ModalRoute.of(context)!.settings.arguments as BrandBooking;
    double width = MediaQuery.of(context).size.width;
    print(brandBooking.review);
    return Scaffold(
      backgroundColor: Color(0xffececec),
      appBar: AppBar(
        backgroundColor: Color(0xffececec),
        title: Text(brandBooking.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(brandBooking.userId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasData) {
                      var userName = snapshot.data!['name'];
                      var userImg = snapshot.data!['img'];
                      var userCity = snapshot.data!['city'];
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                userImg.toString(),
                              ),
                              radius: 35,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    userCity,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
                Wrap(
                  children: [
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('service')
                          .doc(brandBooking
                              .service) // Assuming serviceId is the ID of the service
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Text('Error fetching service data');
                        } else {
                          final serviceData = snapshot.data!;
                          final serviceName = serviceData[
                              'name']; // Replace 'name' with the field containing the service name
                          return _buildDetail("Service", serviceName, width);
                        }
                      },
                    ),
                    _buildDetail(
                        "Date", brandBooking.dateTime.toString(), width),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('employee')
                          .doc(brandBooking
                              .employee) // Assuming employeeId is the ID of the employee
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Text('Error fetching employee data');
                        } else {
                          final employeeData = snapshot.data!;
                          final employeeName = employeeData[
                              'name']; // Replace 'name' with the field containing the employee name
                          return _buildDetail("Stylist", employeeName, width);
                        }
                      },
                    ),
                    _buildDetail(
                        "Total Price", "\$${brandBooking.subtotal}", width),
                  ],
                ),
                if (brandBooking.status == Status.completed)
                  Column(
                    children: [
                      _buildDetail(
                          "Booking Ref", "${brandBooking.id}", width * 4),
                      brandBooking.review != ""
                          ? FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('reviews')
                                  .doc(brandBooking.review)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                if (snapshot.hasData) {
                                  var comment = snapshot.data!['comment'];
                                  var rating = snapshot.data!['rating'];
                                  return _buildDetail(
                                      "Feedback", comment, width * 4,
                                      rating: rating);
                                }
                                return SizedBox.shrink();
                              },
                            )
                          : _buildDetail(
                              "Feedback", "No Rating Given Yet", width * 4),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildDetail(String title, String value, double width,
    {double rating = 0}) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Container(
      width: width * 0.4,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xffececec),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.0,
              color: Color(0xff7c7c7c),
            ),
          ),
          SizedBox(height: 8),
          if (title == "Feedback") ...[
            RatingBar.builder(
              itemSize: 30,
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              ignoreGestures: true,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(rating);
              },
            ),
          ],
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    ),
  );
}
