import 'package:flutter/material.dart';
import 'dart:async';

class SearchBox extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBox({
    Key? key,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Auto-focus on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Listen to text changes
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start new timer (400ms debounce)
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearch(_controller.text.trim());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: const InputDecoration(
        hintText: 'Type-in to search customers ...',
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}
