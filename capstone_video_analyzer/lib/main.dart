import 'package:capstone_video_analyzer/pages/gallery_page.dart';
import 'package:capstone_video_analyzer/pages/search_page.dart';
import 'package:capstone_video_analyzer/pages/signIn_page.dart';
import 'package:capstone_video_analyzer/services/auth_service.dart';
import 'package:capstone_video_analyzer/services/constants.dart';
import 'package:capstone_video_analyzer/services/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


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
      ),
      
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return SearchPage();
    }
    return SignInPage();
  }
}
