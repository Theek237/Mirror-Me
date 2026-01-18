import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  print('🚀 Starting MirrorMe App...');
  WidgetsFlutterBinding.ensureInitialized();
  print('✓ Flutter binding initialized');

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print('✓ Firebase initialized');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  try {
    await initDependencies();
    print('✓ Dependencies initialized');
  } catch (e) {
    print('❌ Dependency initialization error: $e');
  }

  final supabaseUrl = AppConfig.getSupabaseUrl();
  final supabaseKey = AppConfig.getSupabaseAnonKey();
  if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
    try {
      await SupabaseService.initialize(
        supabaseUrl: supabaseUrl,
        supabaseAnonKey: supabaseKey,
      );
      print('✓ Supabase initialized');
    } catch (e) {
      print('⚠️  Supabase initialization error: $e');
    }
  }

  print('🎨 Running app...');
  runApp(const MirrorMeApp());
}

class MirrorMeApp extends StatelessWidget {
  const MirrorMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('📱 Building MirrorMe MaterialApp...');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const AuthGate(),
    );
  }
}
