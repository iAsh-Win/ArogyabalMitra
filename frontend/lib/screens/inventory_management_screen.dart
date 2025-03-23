import 'package:flutter/material.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final List<InventoryItem> _inventoryItems = [
    InventoryItem(
      name: 'Vaccines',
      quantity: 100,
      unit: 'doses',
      category: 'Medical',
      expiryDate: DateTime.now().add(const Duration(days: 180)),
    ),
    InventoryItem(
      name: 'Syringes',
      quantity: 500,
      unit: 'pieces',
      category: 'Equipment',
      expiryDate: DateTime.now().add(const Duration(days: 365)),
    ),
    InventoryItem(
      name: 'Vitamin A',
      quantity: 200,
      unit: 'tablets',
      category: 'Supplements',
      expiryDate: DateTime.now().add(const Duration(days: 90)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInventoryOverview(),
              const SizedBox(height: 24),
              _buildInventoryList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new inventory item
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInventoryOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewCard(
                  'Total Items',
                  _inventoryItems.length.toString(),
                  Icons.inventory_2_outlined,
                ),
                _buildOverviewCard(
                  'Low Stock',
                  '2',
                  Icons.warning_amber_outlined,
                ),
                _buildOverviewCard(
                  'Expiring Soon',
                  '3',
                  Icons.schedule,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildInventoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Inventory Items',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement filter/sort functionality
              },
              icon: const Icon(Icons.filter_list),
              label: const Text('Filter'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _inventoryItems.length,
          itemBuilder: (context, index) {
            final item = _inventoryItems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.medical_services_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(item.name),
                subtitle: Text(
                  '${item.quantity} ${item.unit} - ${item.category}\nExpires: ${item.expiryDate.toString().split(' ')[0]}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    // TODO: Implement edit functionality
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class InventoryItem {
  final String name;
  final int quantity;
  final String unit;
  final String category;
  final DateTime expiryDate;

  InventoryItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.expiryDate,
  });
}