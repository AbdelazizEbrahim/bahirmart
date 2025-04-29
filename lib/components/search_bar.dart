import 'package:flutter/material.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final searchPhrase = _searchController.text.trim();
    if (searchPhrase.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/products',
        arguments: {
          'searchPhrase': searchPhrase,
          'title': 'Search Results',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          ElevatedButton(
            onPressed: _handleSearch,
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}