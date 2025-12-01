import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Pagination extends StatelessWidget {
  final int currentPage;
  final Function(int) onPageChange;
  final bool hasMore;

  const Pagination({
    Key? key,
    required this.currentPage,
    required this.onPageChange,
    required this.hasMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.veryLightGray,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: currentPage <= 1
                ? null
                : () => onPageChange(currentPage - 1),
            child: const Text('Previous'),
          ),
          const SizedBox(width: 20),
          Text(
            'Page $currentPage',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGray,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: !hasMore ? null : () => onPageChange(currentPage + 1),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
