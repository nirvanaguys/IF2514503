import 'package:flutter/material.dart';

class CategoryChipsSelector extends StatelessWidget {
  const CategoryChipsSelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Tanaman (opsional)',
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => onCategorySelected(category),
                  selectedColor: colorScheme.surfaceContainer,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFC7D2C9),
                  ),
                  labelStyle: textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  showCheckmark: true,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
