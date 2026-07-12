import 'package:flutter/material.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/category/home_category_item_widget.dart';

class HomeCategoryListWidget extends StatelessWidget {
  const HomeCategoryListWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryTap,
  });

  final List<HomeCategoryData> categories;
  final String selectedCategoryId;
  final void Function(String categoryId) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppResponsive.value(35, tablet: 45),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: AppResponsive.space(10)),
        itemBuilder: (_, index) {
          final HomeCategoryData category = categories[index];
          return HomeCategoryItemWidget(
            category: category,
            isSelected: selectedCategoryId == category.id,
            onTap: () => onCategoryTap(category.id),
          );
        },
      ),
    );
  }
}
