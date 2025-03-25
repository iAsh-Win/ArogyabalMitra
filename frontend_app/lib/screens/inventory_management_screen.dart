import 'package:flutter/material.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final List<InventoryItem> _inventoryItems = [
    InventoryItem(
      name: 'Balbhog',
      quantity: 100,
      unit: 'packets',
      category: 'Nutritional Supplements',
    ),
    InventoryItem(
      name: 'Iron-Folic Acid syrup',
      quantity: 150,
      unit: 'bottles',
      category: 'Nutritional Supplements',
    ),
    InventoryItem(
      name: 'Poshan Sachet (MNP)',
      quantity: 300,
      unit: 'sachets',
      category: 'Nutritional Supplements',
    ),
    InventoryItem(
      name: 'DFS Namak',
      quantity: 200,
      unit: 'kg',
      category: 'Fortified Foods',
    ),
    InventoryItem(
      name: 'Vitamin A syrup',
      quantity: 100,
      unit: 'bottles',
      category: 'Nutritional Supplements',
    ),
    InventoryItem(
      name: 'Bal Amrit / Bal Shakti',
      quantity: 150,
      unit: 'packets',
      category: 'Nutritional Supplements',
    ),
    InventoryItem(
      name: 'Protein powder',
      quantity: 100,
      unit: 'packets',
      category: 'Nutritional Supplements',
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
        Text(
          'Inventory Items',
          style: Theme.of(context).textTheme.titleLarge,
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
                  '${item.quantity} ${item.unit} - ${item.category}',
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

  InventoryItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
  });
}