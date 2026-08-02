import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/utils/utility.dart';
import 'package:magic_games/view/base/common_button.dart';

Future<ProfileEditResult?> showProfileEditDialog({
  required String initialName,
  required List<String> avatarAssetPaths,
  String? initialSelectedAssetPath,
  String? initialSelectedFilePath,
}) {
  return Get.dialog<ProfileEditResult>(
    ProfileEditDialog(
      initialName: initialName,
      avatarAssetPaths: avatarAssetPaths,
      initialSelectedAssetPath: initialSelectedAssetPath,
      initialSelectedFilePath: initialSelectedFilePath,
    ),
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.76),
  );
}

class ProfileEditDialog extends StatefulWidget {
  const ProfileEditDialog({
    super.key,
    required this.initialName,
    required this.avatarAssetPaths,
    this.initialSelectedAssetPath,
    this.initialSelectedFilePath,
  });

  final String initialName;
  final List<String> avatarAssetPaths;
  final String? initialSelectedAssetPath;
  final String? initialSelectedFilePath;

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final TextEditingController _nameController;
  late String? _selectedAssetPath;
  late String? _selectedFilePath;

  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialName)
      ..addListener(_refresh);

    _selectedAssetPath = _normalizeValue(widget.initialSelectedAssetPath);

    _selectedFilePath = _normalizeValue(widget.initialSelectedFilePath);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_refresh)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);
    final EdgeInsets safeAreaPadding = MediaQuery.paddingOf(context);

    final double calculatedHeight =
        screenSize.height -
        viewInsets.bottom -
        safeAreaPadding.vertical -
        AppResponsive.space(36);

    final double maxDialogHeight = calculatedHeight > 240
        ? calculatedHeight
        : 240;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: AppResponsive.space(18),
        vertical: AppResponsive.space(18),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: AppResponsive.value(360, tablet: 430, largeTablet: 480),
          maxHeight: maxDialogHeight,
        ),
        decoration: BoxDecoration(
          color: AppColors.color1C153F,
          borderRadius: BorderRadius.circular(AppResponsive.value(18)),
          border: Border.all(
            color: AppColors.color6B35F5.withValues(alpha: 0.92),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.3),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            AppResponsive.space(14),
            AppResponsive.space(18),
            AppResponsive.space(14),
            AppResponsive.space(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Spacer(),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Edit Profile'.tr,
                          textAlign: TextAlign.center,
                          style: poppinsW700.copyWith(
                            fontSize: AppResponsive.font(24),
                            color: AppColors.white,
                          ),
                        ),
                        Gap(AppResponsive.space(4)),
                        Text(
                          'Change your avatar and name'.tr,
                          textAlign: TextAlign.center,
                          style: poppinsW500.copyWith(
                            fontSize: AppResponsive.font(12.5),
                            color: AppColors.white.withValues(alpha: 0.92),
                          ),
                        ),
                        Gap(AppResponsive.space(6)),
                        Container(
                          width: AppResponsive.value(170, tablet: 210),
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22AEFF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Get.back<void>();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: AppResponsive.space(46),
                        height: AppResponsive.space(46),
                        decoration: BoxDecoration(
                          color: AppColors.color2A1B59,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.white,
                          size: AppResponsive.space(28),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Gap(AppResponsive.space(14)),
              Container(
                height: 1,
                color: AppColors.color6B35F5.withValues(alpha: 0.28),
              ),
              Gap(AppResponsive.space(14)),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose your Avatar.'.tr,
                  style: poppinsW600.copyWith(
                    fontSize: AppResponsive.font(14),
                    color: AppColors.white,
                  ),
                ),
              ),
              Gap(AppResponsive.space(12)),
              Wrap(
                spacing: AppResponsive.space(12),
                runSpacing: AppResponsive.space(14),
                children: <Widget>[
                  ...widget.avatarAssetPaths.map((final String assetPath) {
                    return _AvatarOptionTile(
                      image: Image.asset(assetPath, fit: BoxFit.cover),
                      isSelected: _selectedAssetPath == assetPath,
                      onTap: () {
                        setState(() {
                          _selectedAssetPath = assetPath;
                          _selectedFilePath = null;
                        });
                      },
                    );
                  }),
                  _GalleryOptionTile(
                    isSelected: _selectedFilePath != null,
                    isLoading: _isPickingImage,
                    imageFilePath: _selectedFilePath,
                    onTap: _pickImageFromGallery,
                  ),
                ],
              ),
              Gap(AppResponsive.space(18)),
              Container(
                height: 1,
                color: AppColors.color6B35F5.withValues(alpha: 0.28),
              ),
              Gap(AppResponsive.space(14)),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Set your Name'.tr,
                  style: poppinsW600.copyWith(
                    fontSize: AppResponsive.font(14),
                    color: AppColors.white,
                  ),
                ),
              ),
              Gap(AppResponsive.space(10)),
              _NameInputField(controller: _nameController),
              Gap(AppResponsive.space(8)),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'This name will be visible to other players.'.tr,
                  style: poppinsW400.copyWith(
                    fontSize: AppResponsive.font(11.5),
                    color: AppColors.white.withValues(alpha: 0.58),
                  ),
                ),
              ),
              Gap(AppResponsive.space(18)),
              CommonButton(
                btnText: 'Save'.tr,
                onPressed: _submit,
                height: AppResponsive.value(48, tablet: 54),
                borderRadius: 10,
                style: poppinsW600.copyWith(
                  fontSize: AppResponsive.font(16),
                  color: AppColors.white,
                ),
              ),
              Gap(AppResponsive.space(10)),
              InkWell(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Get.back<void>();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppResponsive.space(4),
                  ),
                  child: Text(
                    'Cancel'.tr,
                    style: poppinsW600.copyWith(
                      fontSize: AppResponsive.font(14),
                      color: AppColors.color9B57FF,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    if (_isPickingImage) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isPickingImage = true;
    });

    try {
      final List<String> images = await Utility.getPhotos(isMultiple: false);

      if (images.isNotEmpty && mounted) {
        setState(() {
          _selectedFilePath = images.first;
          _selectedAssetPath = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    Get.back<ProfileEditResult>(
      result: ProfileEditResult(
        name: _nameController.text.trim(),
        selectedAssetPath: _selectedAssetPath,
        selectedFilePath: _selectedFilePath,
      ),
    );
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  String? _normalizeValue(final String? value) {
    if (value == null) {
      return null;
    }

    final String trimmedValue = value.trim();

    return trimmedValue.isEmpty ? null : trimmedValue;
  }
}

class _AvatarOptionTile extends StatelessWidget {
  const _AvatarOptionTile({
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  final Widget image;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double size = AppResponsive.value(70, tablet: 78);

    final double badgeSize = AppResponsive.space(28);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size + badgeSize * 0.45,
        height: size + badgeSize * 0.45,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.color8752FF.withValues(alpha: 0.9),
                    width: 2,
                  ),
                ),
                child: ClipOval(child: image),
              ),
            ),
            if (isSelected)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.color752DEA,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: AppResponsive.space(18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GalleryOptionTile extends StatelessWidget {
  const _GalleryOptionTile({
    required this.isSelected,
    required this.isLoading,
    required this.imageFilePath,
    required this.onTap,
  });

  final bool isSelected;
  final bool isLoading;
  final String? imageFilePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double tileSize = AppResponsive.value(78, tablet: 86);

    final double previewSize = AppResponsive.value(60, tablet: 68);

    final bool hasSelectedImage =
        imageFilePath != null && File(imageFilePath!).existsSync();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppColors.color752DEA
                  : AppColors.color6B35F5.withValues(alpha: 0.9),
              width: 1.5,
            ),
            color: AppColors.color1A0B53.withValues(alpha: 0.9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (hasSelectedImage)
                Container(
                  width: previewSize,
                  height: previewSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.color8752FF.withValues(alpha: 0.8),
                    ),
                  ),
                  child: ClipOval(
                    child: Image.file(File(imageFilePath!), fit: BoxFit.cover),
                  ),
                )
              else if (isLoading)
                SizedBox(
                  width: AppResponsive.space(28),
                  height: AppResponsive.space(28),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.color9B57FF,
                    ),
                  ),
                )
              else
                Image.asset(
                  Assets.png.profilePic.icGallery.path,
                  width: AppResponsive.value(34, tablet: 38),
                  height: AppResponsive.value(34, tablet: 38),
                ),
              Gap(AppResponsive.space(6)),
              Text(
                'From Gallery'.tr,
                textAlign: TextAlign.center,
                style: poppinsW400.copyWith(
                  fontSize: AppResponsive.font(9),
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameInputField extends StatelessWidget {
  const _NameInputField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppResponsive.value(50, tablet: 56),
      padding: EdgeInsets.symmetric(horizontal: AppResponsive.space(14)),
      decoration: BoxDecoration(
        color: AppColors.color211557,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.color6B35F5.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.person_rounded,
            color: AppColors.color8752FF.withValues(alpha: 0.8),
            size: AppResponsive.space(20),
          ),
          Gap(AppResponsive.space(10)),
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 20,
              maxLines: 1,
              textInputAction: TextInputAction.done,
              textAlignVertical: TextAlignVertical.center,
              scrollPadding: EdgeInsets.only(
                bottom:
                    MediaQuery.viewInsetsOf(context).bottom +
                    AppResponsive.space(100),
              ),
              onSubmitted: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              style: poppinsW500.copyWith(
                fontSize: AppResponsive.font(14),
                color: AppColors.white,
              ),
              cursorColor: AppColors.white,
              decoration: InputDecoration(
                counterText: '',
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: 'Enter your Name'.tr,
                hintStyle: poppinsW400.copyWith(
                  fontSize: AppResponsive.font(13),
                  color: AppColors.white.withValues(alpha: 0.38),
                ),
              ),
            ),
          ),
          Gap(AppResponsive.space(8)),
          Text(
            '${controller.text.characters.length}/20',
            style: poppinsW400.copyWith(
              fontSize: AppResponsive.font(11),
              color: AppColors.white.withValues(alpha: 0.58),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileEditResult {
  const ProfileEditResult({
    required this.name,
    this.selectedAssetPath,
    this.selectedFilePath,
  });

  final String name;
  final String? selectedAssetPath;
  final String? selectedFilePath;
}
