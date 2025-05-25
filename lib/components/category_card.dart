import 'package:flutter/material.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';
import 'package:bahirmart/core/models/category_model.dart' as cat;

class CategoryCard extends StatelessWidget {
  final cat.Category category;
  final VoidCallback onTap;
  final VoidCallback onSeeMore;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
    required this.onSeeMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSizes.cardElevation,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          child: Column(
            children: [
              Text(
                category.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              TextButton(
                onPressed: onSeeMore,
                child: const Text('See More'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}