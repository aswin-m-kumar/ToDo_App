import 'package:flutter/material.dart';
import 'package:app_ui/app_ui.dart';
import '../login/view/login_page.dart';
import '../signup/view/signup_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(colors, isDark),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildHeroImage(colors),
                    const SizedBox(height: 24),
                    _buildGlassCard(colors),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Join 50,000+ warriors turning their chores into epic adventures.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ColorScheme colors, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.psychology, size: 20, color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: 8),
              Text(
                'QuestDo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: colors.primary,
            ),
            onPressed: toggleTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(ColorScheme colors) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colors.surfaceContainer,
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(child: _buildPlaceholderImage(colors)),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      colors.surface.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.psychology, size: 80, color: colors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'QuestDo',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colors.primary.withValues(alpha: 0.2),
              letterSpacing: -0.02,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(ColorScheme colors) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildSegmentedTabs(colors),
          const SizedBox(height: 24),
          _selectedTab == 0 ? const LoginPage() : const SignupPage(),
          const SizedBox(height: 16),
          _buildDivider(colors),
          const SizedBox(height: 16),
          _buildGoogleButton(colors),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? colors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedTab == 0
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? colors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedTab == 1
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ColorScheme colors) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.outlineVariant)),
      ],
    );
  }

  Widget _buildGoogleButton(ColorScheme colors) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: colors.surfaceContainerHighest,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.g_mobiledata, size: 24, color: colors.onSurface),
            const SizedBox(width: 8),
            Text(
              'Sign up with Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
