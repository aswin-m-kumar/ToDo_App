import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:authentication_client/authentication_client.dart';
import 'package:authentication_repository/authentication_repository.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthenticationRepository _repo;
  late final StreamSubscription<AuthUser?> _userSub;

  AuthCubit(this._repo) : super(const AuthState()) {
    _userSub = _repo.user.listen((user) {
      if (user != null) {
        emit(AuthState(status: AuthStatus.authenticated, user: user));
      } else {
        emit(const AuthState(status: AuthStatus.unauthenticated));
      }
    });
  }

  Future<void> signOut() async {
    await _repo.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override
  Future<void> close() {
    _userSub.cancel();
    return super.close();
  }
}
