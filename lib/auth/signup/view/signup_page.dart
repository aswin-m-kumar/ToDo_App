import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:authentication_repository/authentication_repository.dart';
import '../cubit/signup_cubit.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => SignupCubit(ctx.read<AuthenticationRepository>()),
      child: const _SignupView(),
    );
  }
}

class _SignupView extends StatefulWidget {
  const _SignupView();

  @override
  State<_SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<_SignupView> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;
    final displayName = _displayNameController.text.trim();

    if (email.isEmpty || password.isEmpty) return;
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    context.read<SignupCubit>().signUp(
          email: email,
          password: password,
          displayName: displayName.isNotEmpty ? displayName : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocListener<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state.status == SignupStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Signup failed'),
              backgroundColor: colors.error,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildField(
                colors: colors,
                label: 'Character Name',
                hint: 'EpicHero42',
                icon: Icons.badge_outlined,
                controller: _displayNameController,
                obscure: false,
              ),
              const SizedBox(height: 16),
              _buildField(
                colors: colors,
                label: 'Username or Email',
                hint: 'adventurer@questdo.com',
                icon: Icons.email_outlined,
                controller: _emailController,
                obscure: false,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(colors),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(colors),
              const SizedBox(height: 16),
              _buildSubmitButton(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required ColorScheme colors,
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool obscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: colors.outline),
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

  Widget _buildConfirmPasswordField(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'Confirm Password',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline, color: colors.outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: colors.outline,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
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
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        final loading = state.status == SignupStatus.loading;
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
                        'Create Character',
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
