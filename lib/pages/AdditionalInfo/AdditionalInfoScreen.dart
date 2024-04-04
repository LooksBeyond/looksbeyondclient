import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:looksbeyondclient/pages/Dashboard/dashboard.dart';
import 'package:looksbeyondclient/provider/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdditionalInfoScreen extends StatefulWidget {
  static const String pageName = '/additionalInfo';
  const AdditionalInfoScreen({super.key});

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  final _addressFormKey = GlobalKey<FormState>();

  GlobalKey<FormState> _phoneFormKey = GlobalKey<FormState>();
  TextEditingController phoneTextEditingController = TextEditingController();

  GlobalKey<FormState> _ownerNameFormKey = GlobalKey<FormState>();
  TextEditingController ownerNameTextEditingController =
      TextEditingController();

  bool isLoading = false;

  final List<String> provinces = [
    'Alberta',
    'British Columbia',
    'Manitoba',
    'New Brunswick',
    'Newfoundland and Labrador',
    'Nova Scotia',
    'Ontario',
    'Prince Edward Island',
    'Quebec',
    'Saskatchewan',
  ];

  late AuthenticationProvider authenticationProvider;
  int _currentStep = 0;
  File? _imageFile;
  String? phone;
  String? image;
  String? address;
  String? _street;
  String? _province;
  String? _city;
  String? _zipCode;
  String? owner;

  @override
  void initState() {
    super.initState();
    authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Your Profile'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepContinue: () async {
                  if (_currentStep == 0) {
                    if (_phoneFormKey.currentState!.validate()) {
                      incrementStep();
                    }
                  } else if (_currentStep == 1) {
                    if (_imageFile != null) {
                      incrementStep();
                    }
                  } else if (_currentStep == 2) {
                    if (_addressFormKey.currentState!.validate()) {
                      setState(() {
                        address = _street! +
                            ", " +
                            _city! +
                            ", " +
                            _province! +
                            ", " +
                            _zipCode!;
                      });
                      incrementStep();
                    }
                  } else if (_currentStep == 3) {
                    print("Data completed: " + isDataCompleted().toString());
                    if (isDataCompleted() &&
                        _ownerNameFormKey.currentState!.validate()) {
                      await updateUserDataFields();
                      Navigator.of(context)
                          .pushReplacementNamed(BottomNavBarScreen.pageName);
                    }
                  }
                },
                onStepCancel: () {
                  setState(() {
                    if (_currentStep == 0) {
                      authenticationProvider.signOut(context);
                    }
                    if (_currentStep > 0) {
                      _currentStep -= 1;
                    }
                  });
                },
                controlsBuilder: (
                  BuildContext context,
                  ControlsDetails cd,
                ) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: cd.onStepContinue,
                          child: Text(
                              _currentStep == 3 ? 'Finish' : 'Save & Next'),
                        ),
                        SizedBox(width: 16.0),
                        TextButton(
                          onPressed: cd.onStepCancel,
                          child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                        ),
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    title:
                        _currentStep == 0 ? Text('Phone') : SizedBox.shrink(),
                    content: addPhoneNumber(),
                    isActive: _currentStep == 0,
                  ),
                  Step(
                    title:
                        _currentStep == 1 ? Text('Image') : SizedBox.shrink(),
                    content: addImage(),
                    isActive: _currentStep == 1,
                  ),
                  Step(
                    title:
                        _currentStep == 2 ? Text('Address') : SizedBox.shrink(),
                    content: addAddress(),
                    isActive: _currentStep == 2,
                  ),
                  Step(
                    title: _currentStep == 3
                        ? Text('Owner Name')
                        : SizedBox.shrink(),
                    content: addOwnerName(),
                    isActive: _currentStep == 3,
                  ),
                ],
              ),
            ),
    );
  }

  Widget addPhoneNumber() {
    return Form(
      key: _phoneFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          Text('Add Phone Number'),
          SizedBox(height: 10),
          TextFormField(
            controller: phoneTextEditingController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '(XXX) XXX-XXXX',
            ),
            onChanged: (value) {
              setState(() {
                phone = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              // Regular expression for Canadian phone number
              final RegExp phoneRegex =
                  RegExp(r'^\([1-9]{3}\)\s?[1-9]{3}-[0-9]{4}$');
              if (!phoneRegex.hasMatch(value)) {
                return 'Please enter a valid Canadian phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget addImage() {
    return Column(
      children: [
        Text('Upload Profile Image'),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            _pickImage(ImageSource.gallery);
          },
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
            child: _imageFile == null
                ? const Center(
                    child: Icon(Icons.add_a_photo, size: 40),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<String?> uploadToFirebase() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String timeStamp = DateTime.now().toString();
      String imageName = 'profile_${uid}_$timeStamp.jpg';
      final firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('brandLogo/$uid/$imageName');
      final firebase_storage.UploadTask uploadTask = ref.putFile(_imageFile!);
      print("BRAND ID " + uid);
      await uploadTask.whenComplete(() => null);

      // Get image URL from Firebase Storage
      String imageURI = await ref.getDownloadURL();
      setState(() {
        image = imageURI;
      });

      return image;
    } catch (error) {
      print('Error uploading image: $error');
      // Handle error
    }
  }

  Widget addAddress() {
    return Form(
      key: _addressFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Address'),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Street',
              hintText: 'Enter street address',
            ),
            onChanged: (value) {
              setState(() {
                _street = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a street address';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'City',
              hintText: 'Enter city',
            ),
            onChanged: (value) {
              setState(() {
                _city = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a city';
              }
              return null;
            },
          ),
          DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Province',
            ),
            value: _province,
            onChanged: (value) {
              setState(() {
                _province = value.toString();
              });
            },
            items: provinces.map<DropdownMenuItem<String>>((String province) {
              return DropdownMenuItem<String>(
                value: province,
                child: Text(province),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a province';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Zip Code',
              hintText: 'Enter zip code',
            ),
            onChanged: (value) {
              setState(() {
                _zipCode = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a zip code';
              } else if (!RegExp(r'^[ABCEGHJKLMNPRSTVXY]\d[A-Z] \d[A-Z]\d$')
                  .hasMatch(value)) {
                return 'Please enter a valid Canadian zip code';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget addOwnerName() {
    return Form(
      key: _ownerNameFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Owner Name",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: ownerNameTextEditingController,
            decoration: const InputDecoration(
              labelText: 'Owner Name',
              hintText: 'Enter brand owner name',
            ),
            onChanged: (value) {
              setState(() {
                owner = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  bool isDataCompleted() {
    if (phone != null &&
        _imageFile != null &&
        address != null &&
        owner != null) {
      return true;
    } else {
      return false;
    }
  }

  void incrementStep() {
    setState(() {
      _currentStep += 1;
    });
  }

  Future<void> updateUserDataFields() async {
    setState(() {
      isLoading = true;
    });
    String? imageFromUpload = await uploadToFirebase();
    // print("image url: " + imageFromUpload!);

    Map<String, dynamic> newData = {
      "phone": phone,
      "logo": imageFromUpload,
      "owner": owner,
      "address": address,
      "city": _city,
      "zipcode": _zipCode,
      "province": _province,
      "street": _street
    };

    try {
      // Get the reference to the user document
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('brands')
          .doc(FirebaseAuth.instance.currentUser!.uid);

      // Update specific fields in the document
      await userRef.set(newData, SetOptions(merge: true));

      authenticationProvider.updateLoggedInUser(
          phoneNumber: phone,
          brandlogo: imageFromUpload,
          address: address,
          owner: owner);

      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setBool('isProfileCompleted', true);
      print('User data fields updated successfully');
    } catch (error) {
      print('Error updating user data fields: $error');
      // Handle the error
    }

    setState(() {
      isLoading = false;
    });
  }
}
