import 'package:flutter/material.dart';
import 'models/customer.dart';
import 'services/customer_service.dart';
import 'widgets/search_box.dart';
import 'widgets/customer_list.dart';
import 'widgets/pagination.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer Search',
      theme: AppTheme.theme,
      home: const CustomerSearchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({Key? key}) : super(key: key);

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  List<Customer> _customers = [];
  bool _loading = false;
  String? _error;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initial load will be triggered by SearchBox on mount
  }

  Future<void> _fetchCustomers(String query, int page) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await CustomerService.searchCustomers(query, page);
      setState(() {
        _customers = results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _customers = [];
        _loading = false;
      });
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
    _fetchCustomers(query, 1);
  }

  void _handlePageChange(int page) {
    if (page < 1) return;
    setState(() {
      _currentPage = page;
    });
    _fetchCustomers(_searchQuery, page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                SearchBox(onSearch: _handleSearch),
                const SizedBox(height: 30),
                Expanded(
                  child: CustomerList(
                    customers: _customers,
                    loading: _loading,
                    error: _error,
                  ),
                ),
                if (!_loading && _error == null && _customers.isNotEmpty)
                  Pagination(
                    currentPage: _currentPage,
                    onPageChange: _handlePageChange,
                    hasMore: _customers.length == 100,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
