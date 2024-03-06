import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:looksbeyondclient/firebase_options.dart';
import 'package:looksbeyondclient/provider/AuthProvider.dart';
import 'package:looksbeyondclient/routes.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthenticationProvider>(
      create: (_)=>AuthenticationProvider(),
      child: MaterialApp(
        title: 'Looks Beyond',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Color(0xfffafbfb),
          appBarTheme: AppBarTheme(backgroundColor: Color(0xfffafbfb)),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: appRoutes,
        // home: const LoginPage(),
      ),
    );
  }
}
