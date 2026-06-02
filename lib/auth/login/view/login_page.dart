import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:authentication_repository/authentication_repository.dart';
import '../cubit/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => LoginCubit(ctx.read<AuthenticationRepository>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;
    context.read<LoginCubit>().logIn(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Login failed'),
              backgroundColor: colors.error,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _buildEmailField(colors),
            const SizedBox(height: 16),
            _buildPasswordField(colors),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildSubmitButton(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'Username or Email',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'adventurer@questdo.com',
            prefixIcon: Icon(Icons.email_outlined, color: colors.outline),
            filled: true,
            fillColor: colors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'Password',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline, color: colors.outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: colors.outline,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: colors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ColorScheme colors) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final loading = state.status == LoginStatus.loading;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              disabledBackgroundColor: colors.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start Your Quest',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.rocket_launch, color: colors.onPrimary),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
