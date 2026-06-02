import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:authentication_repository/authentication_repository.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith({LoginStatus? status, String? errorMessage}) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

class LoginCubit extends Cubit<LoginState> {
  final AuthenticationRepository _repo;

  LoginCubit(this._repo) : super(const LoginState());

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    emit(const LoginState(status: LoginStatus.loading));
    try {
      await _repo.signIn(email: email, password: password);
      emit(const LoginState(status: LoginStatus.success));
    } catch (e) {
      emit(LoginState(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void reset() => emit(const LoginState());
}
