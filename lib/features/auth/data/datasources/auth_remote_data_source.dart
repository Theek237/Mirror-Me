import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mm/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> registerWithEmail(
    String email,
    String password,
    String name,
  );
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    debugPrint('AuthDataSource: Starting login...');
    try {
      final response = await supabaseClient.auth
          .signInWithPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception(
              'Login timeout - please check your internet connection',
            ),
          );

      debugPrint('AuthDataSource: Login response received');

      if (response.user == null) {
        throw Exception('Login failed - no user returned');
      }

      debugPrint(
        'AuthDataSource: Login successful for ${response.user!.email}',
      );
      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      debugPrint('AuthDataSource: Login error - $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    debugPrint('AuthDataSource: Starting registration...');
    try {
      final response = await supabaseClient.auth
          .signUp(email: email, password: password, data: {'name': name})
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception(
              'Registration timeout - please check your internet connection',
            ),
          );

      debugPrint('AuthDataSource: Registration response received');

      if (response.user == null) {
        throw Exception('Registration failed - no user returned');
      }

      debugPrint(
        'AuthDataSource: Registration successful for ${response.user!.email}',
      );
      return UserModel.fromSupabaseUser(response.user!, name: name);
    } catch (e) {
      debugPrint('AuthDataSource: Registration error - $e');
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    debugPrint('AuthDataSource: Logging out...');
    await supabaseClient.auth.signOut();
    debugPrint('AuthDataSource: Logout complete');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = supabaseClient.auth.currentUser;
    if (user != null) {
      debugPrint('AuthDataSource: Current user found - ${user.email}');
      return UserModel.fromSupabaseUser(user);
    }
    debugPrint('AuthDataSource: No current user');
    return null;
  }
}
