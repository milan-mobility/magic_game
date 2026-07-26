import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';

class ProfileAvatarWidget extends StatelessWidget {
  const ProfileAvatarWidget({
    super.key,
    this.size,
    this.onEditTap,
    this.assetPath,
    this.filePath,
    this.imageUrl,
  });

  final double? size;
  final VoidCallback? onEditTap;
  final String? assetPath;
  final String? filePath;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final double avatarSize = size ?? AppResponsive.value(85, tablet: 105);

    return SizedBox(
      width: avatarSize + AppResponsive.space(18),
      height: avatarSize + AppResponsive.space(18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.color5820CB, AppColors.color4B21CA],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: ClipOval(child: _buildAvatarImage(avatarSize)),
            ),
          ),
          if (onEditTap != null)
            Positioned(
              right: 15,
              bottom: 15,
              child: InkWell(
                onTap: onEditTap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: AppResponsive.space(32),
                  height: AppResponsive.space(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.color5820CB,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    Assets.svg.icEdit,
                    width: AppResponsive.space(18),
                    height: AppResponsive.space(18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(final double avatarSize) {
    final String? normalizedImageUrl = _normalizedValue(imageUrl);
    if (normalizedImageUrl != null) {
      return Image.network(
        normalizedImageUrl,
        width: avatarSize,
        height: avatarSize,
        fit: BoxFit.cover,
        errorBuilder:
            (
              final BuildContext context,
              final Object error,
              final StackTrace? stackTrace,
            ) {
              return _buildLocalAvatar(avatarSize);
            },
      );
    }

    return _buildLocalAvatar(avatarSize);
  }

  Widget _buildLocalAvatar(final double avatarSize) {
    final String? normalizedFilePath = _normalizedValue(filePath);
    if (normalizedFilePath != null && File(normalizedFilePath).existsSync()) {
      return Image.file(
        File(normalizedFilePath),
        width: avatarSize,
        height: avatarSize,
        fit: BoxFit.cover,
      );
    }

    return _buildAssetAvatar(avatarSize);
  }

  Widget _buildAssetAvatar(final double avatarSize) {
    return Image.asset(
      _normalizedValue(assetPath) ?? 'assets/png/profile_pic/ic_profile_1.png',
      width: avatarSize,
      height: avatarSize,
      fit: BoxFit.cover,
    );
  }

  String? _normalizedValue(final String? value) {
    if (value == null) {
      return null;
    }

    final String trimmedValue = value.trim();
    return trimmedValue.isEmpty ? null : trimmedValue;
  }
}
