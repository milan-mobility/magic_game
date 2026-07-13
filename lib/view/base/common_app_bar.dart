import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/styles.dart';

class CommonAppbar extends StatelessWidget implements PreferredSize {
  const CommonAppbar({
    super.key,
    required this.title,
    this.actions,
    this.onLeading,
    this.backgroundColor,
    this.iconStr,
    this.showLeading = true,
    this.isTitleInCenter = true,
  });

  final String title;
  final List<Widget>? actions;
  final VoidCallback? onLeading;
  final Color? backgroundColor;
  final String? iconStr;
  final bool? showLeading;
  final bool? isTitleInCenter;

  @override
  Widget build(final BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.white,
      backgroundColor: backgroundColor,
      leadingWidth: (isTitleInCenter ?? false) ? 60 : 0,
      leading: (showLeading ?? false)
          ? Transform.flip(
              flipX: Directionality.of(context) == TextDirection.rtl,
              child: GestureDetector(
                onTap:
                    onLeading ??
                    () {
                      Get.back();
                    },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 5, bottom: 5),
                  child: Icon(Icons.arrow_back_ios),
                ),
              ),
            )
          : SizedBox(),
      centerTitle: isTitleInCenter,
      titleSpacing: (isTitleInCenter ?? false) ? 0 : 20,
      title: Text(
        title,
        style: poppinsW500.copyWith(fontSize: 22, color: Colors.black),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget get child => throw UnimplementedError();
}
