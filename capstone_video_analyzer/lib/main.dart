import 'package:capstone_video_analyzer/pages/login_page.dart';
import 'package:capstone_video_analyzer/services/auth_service.dart';
import 'package:capstone_video_analyzer/services/constants.dart';
import 'package:capstone_video_analyzer/services/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'pages/user_library_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
            create: (_) => AuthService(FirebaseAuth.instance)),
        StreamProvider(
            create: (context) => context.read<AuthService>().authStateChanges,
            initialData: null)
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: authenticationRoute,
        debugShowCheckedModeBanner: false,
      ),
      
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return UserLibraryPage();
    }
    return LoginPage();
  }
}
