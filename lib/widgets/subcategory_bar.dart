import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/post_provider.dart';

class SubcategoryBar extends StatelessWidget {
  const SubcategoryBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);

    // 子分类数据
    final categories = [
      CategoryItem(
        value: ExploreCategory.recommended,
        zhLabel: '推荐',
        enLabel: 'Recommended',
        icon: Icons.recommend,
      ),
      CategoryItem(
        value: ExploreCategory.study,
        zhLabel: '学习',
        enLabel: 'Study',
        icon: Icons.school,
      ),
      CategoryItem(
        value: ExploreCategory.activity,
        zhLabel: '活动',
        enLabel: 'Activities',
        icon: Icons.event,
      ),
      CategoryItem(
        value: ExploreCategory.lostFound,
        zhLabel: '失物招领',
        enLabel: 'Lost & Found',
        icon: Icons.find_in_page,
      ),
      CategoryItem(
        value: ExploreCategory.food,
        zhLabel: '美食',
        enLabel: 'Food',
        icon: Icons.restaurant,
      ),
      CategoryItem(
        value: ExploreCategory.accommodation,
        zhLabel: '住宿',
        enLabel: 'Accommodation',
        icon: Icons.hotel,
      ),
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = postProvider.currentCategory == category.value;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appProvider.isEnglish ? category.enLabel : category.zhLabel,
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  postProvider.setCurrentCategory(category.value);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFE53935),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          );
        },
      ),
    );
  }
}

// 分类项数据模型
class CategoryItem {
  final ExploreCategory value;
  final String zhLabel;
  final String enLabel;
  final IconData icon;

  CategoryItem({
    required this.value,
    required this.zhLabel,
    required this.enLabel,
    required this.icon,
  });
}