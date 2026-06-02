import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:authentication_client/authentication_client.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:todo_app/auth/auth.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('https://ykumnokyntchijuabasv.supabase.co'),
    anonKey: const String.fromEnvironment('sb_publishable_uBALk0o5LrqWXxpMysJC4w_Otoir7w_'),
  );

  final authClient = SupabaseAuthenticationClient(Supabase.instance.client);
  final authRepository = AuthenticationRepository(authClient);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationRepository>.value(value: authRepository),
      ],
      child: BlocProvider(
        create: (_) => AuthCubit(authRepository),
        child: const App(),
      ),
    ),
  );
}
