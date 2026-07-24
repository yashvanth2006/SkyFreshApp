import 'package:flutter/material.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;
  final List<String> _statuses = ['Pending', 'Processing', 'Out for Delivery', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final orders = await ApiService.fetchAllOrders();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    final res = await ApiService.updateOrderStatus(orderId, newStatus);
    if (!mounted) return;
    
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
      _loadOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Failed to update status')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Out for Delivery':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _normalizeStatus(String? status) {
    if (status == null) return 'Pending';
    
    // Normalize various status formats to match dropdown values
    final normalized = status.toLowerCase();
    if (normalized == 'placed' || normalized == 'pending') return 'Pending';
    if (normalized == 'processing') return 'Processing';
    if (normalized == 'out for delivery' || normalized == 'out_for_delivery') return 'Out for Delivery';
    if (normalized == 'delivered') return 'Delivered';
    if (normalized == 'cancelled') return 'Cancelled';
    
    // If status is already in the list, return it
    if (_statuses.contains(status)) return status;
    
    // Default fallback
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('Admin Dashboard', style: TextStyle(color: AppTheme.textMain)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _loadOrders,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : _orders.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(Icons.inventory_2_outlined, size: 40, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 16),
                            const Text('No orders yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            const Text('Orders will appear here', style: TextStyle(color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: _orders.length,
                    itemBuilder: (_, i) {
                      final order = _orders[i];
                      final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
                      final rawStatus = order['status']?.toString() ?? 'Pending';
                      final status = _normalizeStatus(rawStatus);
                      final createdAt = DateTime.tryParse(order['createdAt']?.toString() ?? '') ?? DateTime.now();
                      final orderId = order['_id']?.toString() ?? '';
                      final shortId = orderId.length > 6 ? orderId.substring(orderId.length - 6).toUpperCase() : orderId;
                      final customer = order['userId'] is Map ? order['userId'] : {};
                      final customerPhone = customer['phone']?.toString() ?? 'N/A';
                      final customerName = customer['name']?.toString() ?? (customerPhone != 'N/A' ? 'Customer' : 'Guest Customer');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border),
                          boxShadow: [AppTheme.cardShadow.copyWith(blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Order #$shortId', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text(customerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        Text(customerPhone, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${createdAt.day}/${createdAt.month}/${createdAt.year} - ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              ...items.take(3).map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Text(item['emoji']?.toString() ?? '🛒', style: const TextStyle(fontSize: 16)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${item['name']} x${item['quantity']}',
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              if (items.length > 3)
                                Text('+ ${items.length - 3} more item${items.length - 3 == 1 ? '' : 's'}',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${order['totalAmount']}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.primaryDark),
                                  ),
                                  DropdownButton<String>(
                                    value: status,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w600),
                                    underline: const SizedBox(),
                                    items: _statuses.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        _updateStatus(orderId, newValue);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
