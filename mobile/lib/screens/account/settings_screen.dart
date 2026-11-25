import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/profile/profile_header_section.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

  Widget _buildHeader() {
    return SizedBox(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 55),

            const Text(
              'JIRIS',
              style: TextStyle(
                fontFamily: 'Italiana',
                fontSize: 29,
                color: JirisColors.primary,
              ),
            ),

            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: JirisColors.primary,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: JirisColors.primary,
                  ),
                ),
              ],
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

  Widget _buildProfileCard(Map<String, dynamic> user) {
    final name = user['name']?.toString() ?? 'User';
    final email = user['email']?.toString() ?? '-';
    final role = user['role']?.toString() ?? 'Customer';
    final image = user['profile_image']?.toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: JirisColors.lavender,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: JirisColors.border, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: image != null && image.isNotEmpty
                          ? Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _profilePlaceholder(),
                            )
                          : _profilePlaceholder(),
                    ),
                  ),

                  Positioned(
                    right: -3,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: JirisColors.primary,
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 17),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $name!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Italiana',
                        fontSize: 23,
                        color: JirisColors.primary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: JirisColors.primary,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      role[0].toUpperCase() + role.substring(1).toLowerCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: JirisColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final updatedUser = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(user: user),
                  ),
                );

                if (updatedUser != null && mounted) {
                  setState(_loadProfile);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: JirisColors.primary,
                padding: EdgeInsets.zero,
              ),
              child: const Text('Edit profile', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePlaceholder() {
    return const Center(
      child: Icon(Icons.person_outline, size: 42, color: JirisColors.secondary),
    );
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

        // Sama seperti AccountScreen
        padding: EdgeInsets.zero,

        children: [
          // SETTINGS TITLE
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Italiana',
                fontSize: 27,
                color: JirisColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 22),

          ProfileHeaderSection(
            user: user,
            showEditButton: true,
            showBanner: false,
            onEdit: () {
              _openEditProfile(user);
            },
          ),

          const SizedBox(height: 20),

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
                      Navigator.pushReplacementNamed(context, '/customer-home');
                    } else if (index == 1) {
                      Navigator.pushReplacementNamed(context, '/shop');
                    } else if (index == 2) {
                      Navigator.pushReplacementNamed(context, '/categories');
                    } else if (index == 3) {
                      Navigator.pushReplacementNamed(context, '/account');
                    }
                    // else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text(
                    //         '${labels[index]} page belum tersedia.',
                    //       ),
                    //     ),
                    //   );
                    // }
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
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 40,
                              color: JirisColors.secondary,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Unable to load profile',
                              style: TextStyle(color: JirisColors.primary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11),
                            ),
                            const SizedBox(height: 12),
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

                  if (!snapshot.hasData) {
                    return const Center(child: Text('Profile data is empty.'));
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
