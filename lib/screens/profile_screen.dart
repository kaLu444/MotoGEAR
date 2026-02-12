// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:motogear/screens/address_card_screen.dart';
import 'package:motogear/screens/edit_profile_screen.dart';
import 'package:motogear/screens/orders_screen.dart';
import 'package:provider/provider.dart';
import 'wishlist_screen.dart';

import '../consts/app_colors.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),

            if (auth.loading) ...[
              const SizedBox(height: 60),
              const Center(child: CircularProgressIndicator()),
            ] else if (!auth.isLoggedIn) ...[
              _AuthGateCard(
                onLogin: () async {
                  context.read<AuthProvider>().clearError();
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                  if (!mounted) return;
                  context.read<AuthProvider>().clearError();
                },
                onRegister: () async {
                  context.read<AuthProvider>().clearError();
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                  if (!mounted) return;
                  context.read<AuthProvider>().clearError();
                },
              ),
            ] else ...[
              _ProfileHeaderCard(
                name: auth.user!.name,
                email: auth.user!.email,
                onEditProfile: () async {
                  // ✅ prosleđujemo stvarne vrednosti (nema više “Your name” hardkoda)
                  final msg = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        initialName: auth.user!.name,
                        initialEmail: auth.user!.email,
                      ),
                    ),
                  );

                  if (!mounted) return;

                  // očisti error da se ne prenosi
                  context.read<AuthProvider>().clearError();

                  if (msg != null && msg.trim().isNotEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
              ),
              const SizedBox(height: 16),

              _MenuTile(
                icon: Icons.shopping_bag_outlined,
                label: 'Orders',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // ✅ Wishlist sada vodi na WishlistScreen
              _MenuTile(
                icon: Icons.favorite_border_rounded,
                label: 'Wishlist',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // ✅ Addresses više ne vodi na wishlist (placeholder)
              _MenuTile(
                icon: Icons.credit_card_rounded,
                label: 'Address & Card',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddressCardScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x33FFFFFF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => context.read<AuthProvider>().logout(),
                  child: const Text(
                    'Log out',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AuthGateCard extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _AuthGateCard({required this.onLogin, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Log in or create an account to view your profile, orders and addresses.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x33FFFFFF)),
                    backgroundColor: const Color(0xFF151518),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onLogin,
                  child: const Text(
                    'Log in',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alpinestarsRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onRegister,
                  child: const Text(
                    'Register',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onEditProfile;

  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF17171A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF101012),
              border: Border.all(color: const Color(0x22FFFFFF)),
            ),
            child: const Icon(Icons.person, color: Colors.white70, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0x33FFFFFF)),
                      backgroundColor: const Color(0xFF151518),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onEditProfile,
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badgeText;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF17171A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x22000000)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
            if (badgeText != null)
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.alpinestarsRed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    context.read<AuthProvider>().clearError();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
          title: const Text('Log in'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              context.read<AuthProvider>().clearError();
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Field(label: 'Email', controller: _email),
              const SizedBox(height: 12),
              _Field(label: 'Password', controller: _pass, obscure: true),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(
                  message: auth.error!,
                  onDismiss: () => context.read<AuthProvider>().clearError(),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alpinestarsRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: auth.loading
                      ? null
                      : () async {
                          await context.read<AuthProvider>().login(
                            email: _email.text.trim(),
                            password: _pass.text,
                          );

                          if (!mounted) return;

                          if (context.read<AuthProvider>().isLoggedIn) {
                            context.read<AuthProvider>().clearError();
                            Navigator.pop(context);
                          }
                        },
                  child: Text(
                    auth.loading ? 'Loading...' : 'Continue',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    context.read<AuthProvider>().clearError();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: Colors.white,
          title: const Text('Register'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              context.read<AuthProvider>().clearError();
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _Field(label: 'Name', controller: _name),
              const SizedBox(height: 12),
              _Field(label: 'Email', controller: _email),
              const SizedBox(height: 12),
              _Field(label: 'Password', controller: _pass, obscure: true),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(
                  message: auth.error!,
                  onDismiss: () => context.read<AuthProvider>().clearError(),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alpinestarsRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: auth.loading
                      ? null
                      : () async {
                          await context.read<AuthProvider>().register(
                            name: _name.text.trim(),
                            email: _email.text.trim(),
                            password: _pass.text,
                          );

                          if (!mounted) return;

                          if (context.read<AuthProvider>().isLoggedIn) {
                            context.read<AuthProvider>().clearError();
                            Navigator.pop(context);
                          }
                        },
                  child: Text(
                    auth.loading ? 'Loading...' : 'Create account',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;

  const _Field({
    required this.label,
    required this.controller,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF17171A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0F12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x55FF3B30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onDismiss,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
