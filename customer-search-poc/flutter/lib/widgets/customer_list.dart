import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../theme/app_theme.dart';

class CustomerList extends StatelessWidget {
  final List<Customer> customers;
  final bool loading;
  final String? error;

  const CustomerList({
    Key? key,
    required this.customers,
    required this.loading,
    this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            'Error: $error',
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.errorRed,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (customers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            'No customers found',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.lightGray,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Results (${customers.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 2,
                color: AppTheme.veryLightGray,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return _CustomerItem(customer: customer);
            },
          ),
        ),
      ],
    );
  }
}

class _CustomerItem extends StatelessWidget {
  final Customer customer;

  const _CustomerItem({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {}, // Could add navigation to detail page
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${customer.firstName} ${customer.lastName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  Text(
                    'ID: ${customer.id}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: customer.email.map((email) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.veryLightGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
