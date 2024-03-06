import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:looksbeyondclient/models/logged_in_user.dart';
// import 'package:looksbeyond/pages/AdditonalInfo/AdditionalInfoScreen.dart';
// import 'package:looksbeyond/pages/Dashboard/dashboard.dart';
import 'package:looksbeyondclient/provider/AuthProvider.dart';
import 'package:looksbeyondclient/theme.dart';
import 'package:looksbeyondclient/widgets/snackbar.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();

  bool _obscureTextPassword = true;

  late AuthenticationProvider authProvider;
  @override
  void dispose() {
    focusNodeEmail.dispose();
    focusNodePassword.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authProvider = Provider.of<AuthenticationProvider>(context, listen: false);

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 190.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: focusNodeEmail,
                          controller: loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                              fontFamily: 'WorkSansSemiBold',
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: 'Email Address',
                            hintStyle: TextStyle(
                                fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
                          ),
                          onSubmitted: (_) {
                            focusNodePassword.requestFocus();
                          },
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: focusNodePassword,
                          controller: loginPasswordController,
                          obscureText: _obscureTextPassword,
                          style: const TextStyle(
                              fontFamily: 'WorkSansSemiBold',
                              fontSize: 16.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: const Icon(
                              FontAwesomeIcons.lock,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                                fontFamily: 'WorkSansSemiBold', fontSize: 17.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                _obscureTextPassword
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          onSubmitted: (_) {
                             // _login();
                          },
                          textInputAction: TextInputAction.go,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 170.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: CustomTheme.loginGradientStart,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: CustomTheme.loginGradientEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: LinearGradient(
                      colors: <Color>[
                        CustomTheme.loginGradientEnd,
                        CustomTheme.loginGradientStart
                      ],
                      begin: FractionalOffset(0.2, 0.2),
                      end: FractionalOffset(1.0, 1.0),
                      stops: <double>[0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: CustomTheme.loginGradientEnd,
                  child: const Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontFamily: 'WorkSansBold'),
                    ),
                  ),
                  onPressed: (){
                    _login();
                  },
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: TextButton(
                onPressed: () {
                  _showForgotPasswordDialog(context);
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 16.0,
                      fontFamily: 'WorkSansMedium'),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: <Color>[
                          Colors.white10,
                          Colors.white,
                        ],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(1.0, 1.0),
                        stops: <double>[0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    'Or',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontFamily: 'WorkSansMedium'),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: <Color>[
                          Colors.white,
                          Colors.white10,
                        ],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(1.0, 1.0),
                        stops: <double>[0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: 100.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: SignInButton(
                  Buttons.Google,
                  text: "Sign in with Google",
                  onPressed: () {
                    return CustomSnackBar(
                        context, const Text('Google button pressed'));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _login() async {
    String email = loginEmailController.text.trim();
    String password = loginPasswordController.text.trim();

    try {
      // Sign in with email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();


      if (userSnapshot.exists && userSnapshot.data() != null) {
        // Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'lastLoggedIn': DateTime.now().millisecondsSinceEpoch,
      });

        LoggedInUser? loggedInUser = await authProvider.initLoggedInUser(FirebaseAuth.instance.currentUser);
        // Check if the required fields exist in the user document
        if (loggedInUser!.address != "" && loggedInUser.age != 0 && loggedInUser.phoneNumber != "" && loggedInUser.profileImage != "") {
          // User has all the necessary information, navigate to home page
          // Navigator.of(context).pushReplacementNamed(BottomNavBarScreen.pageName);
        } else {
          // User is missing some information, navigate to complete profile page
          // Navigator.of(context).pushReplacementNamed(AdditionalInfoScreen.pageName);
        }
      } else {
        // User document does not exist, handle accordingly
      }
    } catch (error) {
      // Handle login errors
      print('Error logging in: $error');
    }
  }

  void _toggleSignInButton() {
    CustomSnackBar(context, const Text('Login button pressed'));
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }


  void _showForgotPasswordDialog(BuildContext context) {
    String email = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Forgot Password"),
          content: TextField(
            onChanged: (value) {
              email = value;
            },
            decoration: InputDecoration(
              hintText: "Enter your email",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _resetPassword(email, context);
              },
              child: Text("Reset Password"),
            ),
          ],
        );
      },
    );
  }

  void _resetPassword(String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.of(context).pop();
      _showSuccessDialog(context);
    } catch (e) {
      print("Error sending reset password email: $e");
      _showErrorDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Password reset email sent successfully."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Failed to send password reset email. Please try again later."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

}