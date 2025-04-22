import 'package:contact_trace/screens/register_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TraceApp());
}

class TraceApp extends StatelessWidget {
  const TraceApp({super.key});

  //CONTACT TRACING TODO:
  //1) Register a) client b) establishment - Firebase Auth - just for the client; Firebase Firestore storing account
  //2) Login - Firebase Auth
  //3) Scanning QR codes
  //4) Generate QR codes
  //5) Log/Trace - Firebase Firestore
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: RegisterClientScreen());
  }
}
