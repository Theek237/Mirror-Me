import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();

  final supabaseUrl = AppConfig.getSupabaseUrl();
  final supabaseKey = AppConfig.getSupabaseAnonKey();
  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    await SupabaseService.initialize(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseKey,
    );
  }

  runApp(const MirrorMeApp());
}

class MirrorMeApp extends StatelessWidget {
  const MirrorMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const AuthGate(),
    );
  }
}
