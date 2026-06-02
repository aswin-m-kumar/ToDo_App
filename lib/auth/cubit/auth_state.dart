import 'package:equatable/equatable.dart';
import 'package:authentication_client/authentication_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthUser? user;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, user];
}
