import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/error_handler.dart';
import '../providers/auth_provider.dart';

/// Variation B — hero + social-first (recommended in design handoff).
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          // Hero area
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF2D5A1B), Color(0xFF4A7C2E)],
                    ),
                  ),
                  child: const Center(
                    child: Text('🌿', style: TextStyle(fontSize: 120)),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey gardener 👋',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Let's grow something good.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Auth buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
            child: Column(
              children: [
                _SocialButton(
                  label: 'Continue with Google',
                  icon: '🇬',
                  primary: true,
                  onPressed: () async {
                    try {
                      await ref.read(authProvider.notifier).loginWithGoogle();
                      if (context.mounted) context.go(AppRoutes.home);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(friendlyError(e)),
                          action: SnackBarAction(
                            label: 'Dismiss',
                            onPressed: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                _SocialButton(
                  label: 'Continue with Apple',
                  icon: '',
                  icon2: Icons.apple,
                  onPressed: () {
                    // TODO: implement Apple Sign-In
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Apple auth coming soon')),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _SocialButton(
                  label: 'Continue with Email',
                  icon: '✉',
                  onPressed: () => _showEmailSheet(context, ref),
                ),
                const SizedBox(height: 12),
                Text(
                  'By continuing you agree to our Terms of Service',
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EmailLoginSheet(ref: ref),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String icon;
  final IconData? icon2;
  final bool primary;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    this.icon2,
    this.primary = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon.isNotEmpty) Text(icon, style: const TextStyle(fontSize: 16)),
              if (icon2 != null) Icon(icon2, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon.isNotEmpty) Text(icon, style: const TextStyle(fontSize: 16)),
            if (icon2 != null) Icon(icon2, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _EmailLoginSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _EmailLoginSheet({required this.ref});

  @override
  ConsumerState<_EmailLoginSheet> createState() => _EmailLoginSheetState();
}

class _EmailLoginSheetState extends ConsumerState<_EmailLoginSheet> {
  bool _isSignUp = false;
  final _nameCtrl = TextEditingController();
  final _handleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 22, right: 22, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isSignUp ? 'Create account' : 'Sign in', style: tt.headlineMedium),
          const SizedBox(height: 16),
          if (_isSignUp) ...[
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _handleCtrl,
              decoration: const InputDecoration(labelText: 'Username', prefixText: '@'),
            ),
            const SizedBox(height: 10),
          ],
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordCtrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isSignUp ? 'Create account' : 'Sign in'),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () => setState(() { _isSignUp = !_isSignUp; _error = null; }),
              child: Text(
                _isSignUp
                    ? 'Already have an account? Sign in'
                    : "Don't have an account? Sign up",
                style: tt.bodySmall?.copyWith(decoration: TextDecoration.underline),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (_isSignUp) {
        if (_nameCtrl.text.trim().isEmpty || _handleCtrl.text.trim().isEmpty) {
          setState(() { _error = 'Please fill in all fields'; _loading = false; });
          return;
        }
        await ref.read(authProvider.notifier).signupWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          name: _nameCtrl.text.trim(),
          handle: _handleCtrl.text.trim(),
        );
      } else {
        await ref.read(authProvider.notifier).loginWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
      }
      if (mounted) {
        Navigator.pop(context);
        context.go(AppRoutes.home);
      }
    } catch (e) {
      setState(() { _error = friendlyError(e); _loading = false; });
    }
  }
}
