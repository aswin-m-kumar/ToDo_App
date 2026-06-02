import 'dart:async';

import 'package:authentication_client/authentication_client.dart';

class AuthenticationRepository {
  final AuthenticationClient _client;

  AuthenticationRepository(this._client);

  Stream<AuthUser?> get user => _client.user;

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _client.signUp(email: email, password: password, displayName: displayName);

  Future<void> signIn({
    required String email,
    required String password,
  }) =>
      _client.signIn(email: email, password: password);

  Future<void> signOut() => _client.signOut();
}
