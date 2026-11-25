import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';
import 'package:mobile/widgets/profile/profile_header_section.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late Map<String, dynamic> _currentUser;

  final TextEditingController _phoneController = TextEditingController();

  bool _isPrivate = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _currentUser = Map<String, dynamic>.from(widget.user);

    _nameController = TextEditingController(
      text: widget.user['name']?.toString() ?? '',
    );

    _emailController = TextEditingController(
      text: widget.user['email']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedUser = await AuthService.updateProfile(name: name);

      if (!mounted) return;

      Navigator.pop(context, updatedUser);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAndUploadImage({required bool isBanner}) async {
    if (_isUploadingImage || _isSaving) return;

    try {
      final picker = ImagePicker();

      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedImage == null) return;

      setState(() => _isUploadingImage = true);

      final updatedUser = await AuthService.updateProfileImage(
        image: File(pickedImage.path),
        isBanner: isBanner,
      );

      if (!mounted) return;

      setState(() {
        _currentUser = updatedUser;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBanner
                ? 'Banner berhasil diperbarui.'
                : 'Foto profil berhasil diperbarui.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _removePhoto() async {
    if (_isUploadingImage || _isSaving) return;

    try {
      final updatedUser = await AuthService.removeProfileImage();

      if (!mounted) return;

      setState(() {
        _currentUser = updatedUser;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo removed successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 65,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 17,
                color: JirisColors.secondary,
              ),
            ),
            const Spacer(),
            const Text(
              'JIRIS',
              style: TextStyle(
                fontFamily: 'Italiana',
                fontSize: 28,
                color: JirisColors.primary,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              icon: const Icon(
                Icons.settings_outlined,
                color: JirisColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: JirisColors.primary),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: const TextStyle(fontSize: 13, color: JirisColors.primary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: JirisColors.textSecondary,
            ),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 17,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: JirisColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: JirisColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInformation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal information',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: JirisColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Keep your account details up to date.',
            style: TextStyle(fontSize: 11, color: JirisColors.textSecondary),
          ),
          const SizedBox(height: 22),

          _buildInput(
            label: 'Full name',
            controller: _nameController,
            hint: 'Enter your full name',
          ),

          const SizedBox(height: 18),

          _buildInput(
            label: 'Email address',
            controller: _emailController,
            readOnly: true,
          ),

          const SizedBox(height: 18),

          _buildInput(
            label: 'Phone number (optional)',
            controller: _phoneController,
            hint: 'Enter your phone number',
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Private dream room',
                  style: TextStyle(fontSize: 11, color: JirisColors.primary),
                ),
              ),
              Switch(
                value: _isPrivate,
                activeThumbColor: Colors.white,
                activeTrackColor: JirisColors.primary,
                onChanged: (value) {
                  setState(() => _isPrivate = value);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: JirisButton(
                  text: 'Cancel',
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: JirisButton(
                  text: _isSaving ? 'Saving...' : 'Save changes',
                  onPressed: _isSaving ? null : _saveChanges,
                ),
              ),
            ],
          ),

          // Row(
          //   children: [
          //     Expanded(
          //       child: OutlinedButton(
          //         onPressed: _isSaving
          //             ? null
          //             : () => Navigator.pop(context),
          //         style: OutlinedButton.styleFrom(
          //           foregroundColor: JirisColors.primary,
          //           side: const BorderSide(
          //             color: JirisColors.border,
          //           ),
          //           padding: const EdgeInsets.symmetric(
          //             vertical: 17,
          //           ),
          //           shape: const StadiumBorder(),
          //         ),
          //         child: const Text('Cancel'),
          //       ),
          //     ),

          //     Expanded(
          //       child: ElevatedButton(
          //         onPressed: _isSaving ? null : _saveChanges,
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: JirisColors.primary,
          //           foregroundColor: Colors.white,
          //           padding: const EdgeInsets.symmetric(
          //             vertical: 17,
          //           ),
          //           shape: const StadiumBorder(),
          //         ),
          //         child: _isSaving
          //             ? const SizedBox(
          //                 width: 18,
          //                 height: 18,
          //                 child: CircularProgressIndicator(
          //                   strokeWidth: 2,
          //                   color: Colors.white,
          //                 ),
          //               )
          //             : const Text('Save changes'),
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Your information is only used to manage your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: JirisColors.textSecondary),
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
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ProfileHeaderSection(
                    user: _currentUser,
                    showPhotoActions: true,
                    showBannerAction: true,

                    onChangePhoto: () {
                      _pickAndUploadImage(isBanner: false);
                    },

                    onRemovePhoto: () {
                      _removePhoto();
                    },

                    onChangeBanner: () {
                      _pickAndUploadImage(isBanner: true);
                    },
                  ),

                  _buildPersonalInformation(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
