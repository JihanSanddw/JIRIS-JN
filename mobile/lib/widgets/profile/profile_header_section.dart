import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';

class ProfileHeaderSection extends StatelessWidget {
  final Map<String, dynamic> user;

  final bool showEditButton;
  final bool showPhotoActions;
  final bool showBannerAction;
  final bool showBanner;

  final VoidCallback? onEdit;
  final VoidCallback? onChangePhoto;
  final VoidCallback? onRemovePhoto;
  final VoidCallback? onChangeBanner;

  const ProfileHeaderSection({
    super.key,
    required this.user,
    this.showEditButton = false,
    this.showPhotoActions = false,
    this.showBannerAction = false,
    this.showBanner = true,
    this.onEdit,
    this.onChangePhoto,
    this.onRemovePhoto,
    this.onChangeBanner,
  });

  String get _name => user['name']?.toString() ?? 'User';

  String get _email => user['email']?.toString() ?? '-';

  String get _role {
    final value = user['role']?.toString() ?? 'Customer';

    if (value.isEmpty) return 'Customer';

    return value[0].toUpperCase() +
        value.substring(1).toLowerCase();
  }

  String? get _profileImage => user['profile_image']?.toString();

  String? get _bannerImage => user['banner_image']?.toString();

  @override
  Widget build(BuildContext context) {
    if (!showBanner) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        child: _buildProfileCard(),
      );
    }

    return SizedBox(
      height: 350,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBanner(),
          Positioned(
            top: 153,
            left: 20,
            right: 20,
            child: _buildProfileCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 196,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_bannerImage != null && _bannerImage!.isNotEmpty)
            Image.network(
              _bannerImage!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _bannerPlaceholder(),
            )
          else
            _bannerPlaceholder(),

          if (showBannerAction)
            Positioned(
              top: 14,
              right: 20,
              child: _actionButton(
                label: 'Change banner',
                onPressed: onChangeBanner,
              ),
            ),
        ],
      ),
    );
  }

  Widget _bannerPlaceholder() {
    return Container(
      color: JirisColors.lavender,
      child: const Center(
        child: Icon(
          Icons.chair_outlined,
          size: 48,
          color: JirisColors.secondary,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
      decoration: BoxDecoration(
        color: JirisColors.lavender,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: JirisColors.border,
          width: 0.7,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfileImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $_name!',
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
                      _email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: JirisColors.primary,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      _role,
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

          if (showEditButton || showPhotoActions) ...[
            const SizedBox(height: 12),

            if (showEditButton)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: JirisColors.primary,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'Edit profile',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),

            if (showPhotoActions)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: onChangePhoto,
                    style: TextButton.styleFrom(
                      foregroundColor: JirisColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Change photo',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: onRemovePhoto,
                    style: TextButton.styleFrom(
                      foregroundColor: JirisColors.primary,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Remove',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  // PROFILE IMAGE
  Widget _buildProfileImage() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: _profileImage != null && _profileImage!.isNotEmpty
                ? Image.network(
                    _profileImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _profilePlaceholder(),
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
    );
  }

  Widget _profilePlaceholder() {
    return const Center(
      child: Icon(
        Icons.person_outline,
        size: 42,
        color: JirisColors.secondary,
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: JirisColors.lavender,
        foregroundColor: JirisColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 7,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}
