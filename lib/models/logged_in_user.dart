import 'package:cloud_firestore/cloud_firestore.dart';

class LoggedInUser {
  final String uid;
  final String name;
  final String email;
  String phoneNumber;
  String profileImage;
  String address;
  int age;
  final DocumentSnapshot snapshot;

  LoggedInUser(
      {required this.age,
      required this.name,
      required this.email,
      required this.phoneNumber,
      required this.profileImage,
      required this.address,
      required this.uid,
      required this.snapshot});

  factory LoggedInUser.fromFireStore(DocumentSnapshot snapshot) {
    var data = snapshot.data()! as Map<String, dynamic>;
    print("USER DATA IS::");
    print(data);

    var loggedInUser = LoggedInUser(
      uid: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phone'] ?? '',
      profileImage: data['img'] ?? '',
      address: data['address'] ?? '',
      age: data['age'] ?? 0,
      snapshot: snapshot,
    );

    return loggedInUser;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Profile image: ${this.profileImage}, Phone: ${this.phoneNumber}, Address: ${this.address}, Age: ${this.age}, name: ${this.name}";

  }
}
