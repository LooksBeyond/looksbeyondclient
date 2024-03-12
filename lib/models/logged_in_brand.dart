import 'package:cloud_firestore/cloud_firestore.dart';

class LoggedInBrand {
  final String uid;
  final String brand;
  final String email;
  String phoneNumber;
  String brandLogo;
  String address;
  String owner;
  List employees;
  final DocumentSnapshot snapshot;

  LoggedInBrand(
      {required this.owner,
      required this.brand,
      required this.email,
      required this.phoneNumber,
      required this.brandLogo,
      required this.address,
      required this.uid,
      required this.employees,
      required this.snapshot});

  factory LoggedInBrand.fromFireStore(DocumentSnapshot snapshot) {
    var data = snapshot.data()! as Map<String, dynamic>;
    print("USER DATA IS::");
    print(data);

    var loggedInUser = LoggedInBrand(
      employees: data['employees'] ?? [],
      uid: snapshot.id,
      brand: data['brand'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phone'] ?? '',
      brandLogo: data['logo'] ?? '',
      address: data['address'] ?? '',
      owner: data['owner'] ?? '',
      snapshot: snapshot,
    );

    return loggedInUser;
  }

  @override
  String toString() {
    return "LOGGED IN BRAND::: Profile image: ${this.brandLogo}, Phone: ${this.phoneNumber}, Address: ${this.address}, Age: ${this.owner}, name: ${this.brand}";
  }
}
