import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/screens/account/edit_profile_screen.dart';
import 'package:mobile/services/auth_service.dart';
// import 'package:mobile/services/order_service.dart';
import 'package:mobile/widgets/profile/profile_header_section.dart';

class AdminAccountScreen extends StatefulWidget {
  const AdminAccountScreen({super.key});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = AuthService.getProfile();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: JirisColors.surface,
        title: const Text(
          'Sign out?',
          style: TextStyle(
            fontFamily: 'Italiana',
            fontSize: 24,
            color: JirisColors.primary,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out of your account?',
          style: TextStyle(fontSize: 13, color: JirisColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Sign out',
              style: TextStyle(color: JirisColors.primary),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _loadProfile();
    });

    try {
      await Future.wait([_profileFuture]);
    } catch (_) {}
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
      child: Row(
        children: [
          const Text(
            'JIRIS',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 29,
              color: JirisColors.primary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: JirisColors.lavender,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ADMIN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: JirisColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: JirisColors.secondary,
            ),

            const SizedBox(height: 14),

            const Text(
              'Unable to load profile',
              style: TextStyle(fontSize: 16, color: JirisColors.primary),
            ),

            const SizedBox(height: 8),

            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: JirisColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                setState(_loadProfile);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditProfile(Map<String, dynamic> user) async {
    final updatedUser = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
    );

    if (!mounted) return;

    if (updatedUser != null) {
      setState(() {
        _loadProfile();
      });
    }
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return Material(
      color: JirisColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JirisColors.border, width: 0.8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: JirisColors.primary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: JirisColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(icon, size: 20, color: JirisColors.secondary),

              if (showArrow) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: JirisColors.secondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(Map<String, dynamic> user) {
    return RefreshIndicator(
      color: JirisColors.primary,
      onRefresh: () async {
        setState(_loadProfile);
        try {
          await _profileFuture;
        } catch (_) {}
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: EdgeInsets.zero,

        children: [
          ProfileHeaderSection(
            user: user,
            showEditButton: true,
            // showBanner: false,
            onEdit: () {
              _openEditProfile(user);
            },
          ),

          // const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildMenuItem(
                  title: 'Personal information',
                  subtitle: '${user['name'] ?? 'User'} · Manage your details',
                  icon: Icons.person_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(user: user),
                      ),
                    ).then((_) {
                      if (mounted) setState(_loadProfile);
                    });
                  },
                ),

                const SizedBox(height: 16),

                _buildMenuItem(
                  title: 'Password & security',
                  subtitle: 'Update your password',
                  icon: Icons.chevron_right,
                  showArrow: false,
                  onTap: () {
                    _showMessage(
                      'Password & security will be implemented next.',
                    );
                  },
                ),

                const SizedBox(height: 16),

                _buildMenuItem(
                  title: 'Contact JIRIS',
                  subtitle: 'Questions? We’re here to help.',
                  icon: Icons.mail_outline,
                  onTap: () {
                    _showMessage('Contact JIRIS will be available soon.');
                  },
                ),

                const SizedBox(height: 16),

                _buildMenuItem(
                  title: 'Sign out',
                  subtitle: '',
                  icon: Icons.logout,
                  onTap: _signOut,
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'JIRIS · Considered living.\n'
                    'Terms of Service  ·  Privacy Policy',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.5,
                      color: JirisColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    const icons = [
      Icons.home_outlined,
      Icons.shopping_bag_outlined,
      Icons.grid_view_outlined,
      Icons.person_outline,
    ];

    const labels = ['Home', 'Shop', 'Categories', 'Account'];

    return Container(
      decoration: const BoxDecoration(
        color: JirisColors.surface,
        border: Border(top: BorderSide(color: JirisColors.border, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (index == 0) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin-dashboard',
                      );
                    } else if (index == 1) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin-products',
                      );
                    } else if (index == 2) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin-categories',
                      );
                    } else if (index == 3) {
                      Navigator.pushReplacementNamed(context, '/account');
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        size: 20,
                        color: index == 3
                            ? JirisColors.primary
                            : JirisColors.textSecondary,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 9,
                          color: index == 3
                              ? JirisColors.primary
                              : JirisColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JirisColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: JirisColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildError(snapshot.error!);
                  }

                  if (!snapshot.hasData) {
                    return _buildError(Exception('Profile data is empty.'));
                  }

                  return _buildSettingsContent(snapshot.data!);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
