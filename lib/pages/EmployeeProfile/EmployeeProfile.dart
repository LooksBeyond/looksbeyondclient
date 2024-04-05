import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:looksbeyondclient/models/brand_booking.dart';

class EmployeeProfile extends StatefulWidget {
  static const String pageName = '/employeeProfile';
  const EmployeeProfile({Key? key}) : super(key: key);

  @override
  State<EmployeeProfile> createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  @override
  Widget build(BuildContext context) {
    final employee =
        ModalRoute.of(context)!.settings.arguments as DocumentSnapshot;

    void _deleteEmployee() {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            title: Text("Delete Employee"),
            content: Text("Are you sure you want to delete this employee?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  // Perform soft deletion by updating the "deleted" flag
                  FirebaseFirestore.instance
                      .collection('employees')
                      .doc(employee.id)
                      .update({
                    'deleted': true,
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Employee deleted successfully'),
                    ));
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to delete employee: $error'),
                    ));
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text("Delete"),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          employee.get('name'),
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Coming soon")),
                );
              },
              icon: Icon(Icons.edit))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: double.infinity,
              height: 200,
              child: CachedNetworkImage(
                imageUrl: employee.get(
                    'img'), // Replace with the field containing the image URL
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20.0),
            // Display employee information
            Text(
              'Name: ${employee['name']}',
              style: TextStyle(fontSize: 20.0),
            ),
            Text(
              'Email: ${employee['email']}',
              style: TextStyle(fontSize: 20.0),
            ),
            // Add more fields as needed

            // Display employee services
            SizedBox(height: 20.0),
            Text(
              'Services:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: employee['services'].entries.map<Widget>((entry) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('service')
                      .doc(entry.key) // Service ID
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else {
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          !snapshot.data!.exists) {
                        return Text('No Services Found');
                      } else {
                        final service = snapshot.data!;
                        return Text(
                          '- ${service['name']} - Price: ${entry.value}',
                          style: TextStyle(fontSize: 16.0),
                        );
                      }
                    }
                  },
                );
              }).toList(),
            ),

            // Display employee reviews
            SizedBox(height: 20.0),
            Text(
              'Reviews:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('empId', isEqualTo: employee.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text('No Reviews yet');
                } else if (snapshot.hasData) {
                  final reviews = snapshot.data!.docs;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: reviews.map<Widget>((review) {
                      return ListTile(
                        title: Text(review['userName']),
                        subtitle: Text(review['comment']),
                      );
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),

            SizedBox(height: 20.0),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All Bookings",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('employee', isEqualTo: employee.id)
                      .where('status', isEqualTo: 'completed')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('No completed bookings found.'),
                      );
                    }

                    final bookings = snapshot.data!.docs;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: bookings.map<Widget>((document) {
                        final booking = BrandBooking.fromFireStore(document);
                        return ListTile(
                          title: Text('Booking ID: ${booking.id}'),
                          subtitle: Text('Title: ${booking.title}'),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
