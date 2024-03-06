import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final List employees;
  final String owner;

  Brand(
      {required this.id,
      required this.name,
      required this.address,
      required this.imageUrl,
      required this.employees,
      required this.owner});

  factory Brand.fromFirebase(DocumentSnapshot snapshot) {
    var data = snapshot.data()! as Map<String, dynamic>;

    var brand = Brand(
        id: snapshot.id,
        name: data['brand'],
        address: data['address'],
        imageUrl: data['logo'],
        employees: data['employees'],
        owner: data['owner']);

    return brand;
  }
}

// List<Client> ClientList = [
//   Client(
//     name: 'Client A',
//     address: 'Address of Client A',
//     imageUrl: 'assets/img/avatar.png',
//   ),
//   Client(
//     name: 'Client B',
//     address: 'Address of Client B',
//     imageUrl: 'assets/img/avatar.png',
//   ),
//   Client(
//     name: 'Client C',
//     address: 'Address of Client C',
//     imageUrl: 'assets/img/avatar.png',
//   ),
//   Client(
//     name: 'Client D',
//     address: 'Address of Client D',
//     imageUrl: 'assets/img/avatar.png',
//   ),
//   Client(
//     name: 'Client E',
//     address: 'Address of Client E',
//     imageUrl: 'assets/img/avatar.png',
//   ),
// ];
