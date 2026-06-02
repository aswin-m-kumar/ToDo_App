import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUser {
  final String id;
  final String email;
  final String? displayName;

  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
  });
}

abstract class AuthenticationClient {
  Stream<AuthUser?> get user;
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  Future<void> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
}

class SupabaseAuthenticationClient implements AuthenticationClient {
  final SupabaseClient _supabase;

  SupabaseAuthenticationClient(this._supabase);

  @override
  Stream<AuthUser?> get user =>
      _supabase.auth.onAuthStateChange.map((event) {
        final u = event.session?.user;
        if (u == null) return null;
        return AuthUser(
          id: u.id,
          email: u.email ?? '',
          displayName: u.userMetadata?['display_name'] as String?,
        );
      });

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _supabase.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) =>
      _supabase.auth.signInWithPassword(email: email, password: password);

  @override
  Future<void> signOut() => _supabase.auth.signOut();
}
