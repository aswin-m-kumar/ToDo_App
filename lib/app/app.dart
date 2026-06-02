import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';
import 'package:todo_app/auth/auth.dart';
import 'package:todo_app/todo/view/todo_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeModeNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: 'QuestDo',
          debugShowCheckedModeBanner: false,
          theme: QuestDoTheme.light,
          darkTheme: QuestDoTheme.dark,
          themeMode: themeModeNotifier.value,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              switch (state.status) {
                case AuthStatus.authenticated:
                  return const TodoPage();
                case AuthStatus.unauthenticated:
                  return const AuthPage();
                case AuthStatus.unknown:
                  return const _SplashScreen();
              }
            },
          ),
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 64, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              'QuestDo',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: colors.primary,
                letterSpacing: -0.02,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: colors.primary),
          ],
        ),
      ),
    );
  }
}
