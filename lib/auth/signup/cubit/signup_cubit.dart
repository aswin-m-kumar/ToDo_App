import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:authentication_repository/authentication_repository.dart';

enum SignupStatus { initial, loading, success, failure }

class SignupState extends Equatable {
  final SignupStatus status;
  final String? errorMessage;

  const SignupState({
    this.status = SignupStatus.initial,
    this.errorMessage,
  });

  SignupState copyWith({SignupStatus? status, String? errorMessage}) {
    return SignupState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}

class SignupCubit extends Cubit<SignupState> {
  final AuthenticationRepository _repo;

  SignupCubit(this._repo) : super(const SignupState());

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(const SignupState(status: SignupStatus.loading));
    try {
      await _repo.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      emit(const SignupState(status: SignupStatus.success));
    } catch (e) {
      emit(SignupState(
        status: SignupStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void reset() => emit(const SignupState());
}
