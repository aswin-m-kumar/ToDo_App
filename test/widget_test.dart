import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:authentication_client/authentication_client.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:todo_app/app/app.dart';
import 'package:todo_app/auth/auth.dart';

class _FakeAuthClient implements AuthenticationClient {
  final _controller = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> get user => _controller.stream;

  @override
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {}

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}

  void dispose() => _controller.close();

  void emitUser(AuthUser? user) => _controller.add(user);
}

Widget _createTestApp() {
  final fakeClient = _FakeAuthClient();
  final authRepository = AuthenticationRepository(fakeClient);

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<AuthenticationRepository>.value(value: authRepository),
    ],
    child: BlocProvider(
      create: (_) => AuthCubit(authRepository),
      child: const App(),
    ),
  );
}

void main() {
  testWidgets('App renders splash screen on startup', (tester) async {
    await tester.pumpWidget(_createTestApp());
    await tester.pump();

    expect(find.text('QuestDo'), findsOneWidget);
  });
}
