import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mm/firebase_options.dart';
import 'injection_container.dart' as di;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Initialize Dependency Injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Virtual Wardrobe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text("AI Wardrobe Initialized!"),
        ),
      ),
    );
  }
}