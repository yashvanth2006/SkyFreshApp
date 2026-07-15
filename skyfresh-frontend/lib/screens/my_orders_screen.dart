import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/models/user_profile.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final orders = await ApiService.getMyOrders();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppTheme.primary;
      case 'cancelled':
        return Colors.redAccent;
      case 'out_for_delivery':
        return Colors.orange;
      default:
        return AppTheme.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
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
                              child: const Icon(Icons.shopping_bag_outlined, size: 40, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 16),
                            const Text('No orders yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            const Text('Your order history will appear here', style: TextStyle(color: AppTheme.textMuted)),
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
                      final status = order['status']?.toString() ?? 'placed';
                      final createdAt = DateTime.tryParse(order['createdAt']?.toString() ?? '') ?? DateTime.now();
                      final orderId = order['_id']?.toString() ?? '';
                      final shortId = orderId.length > 6 ? orderId.substring(orderId.length - 6).toUpperCase() : orderId;

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
                                  Text('Order #$shortId', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      formatOrderStatus(status),
                                      style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(formatRelativeTime(createdAt), style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              const SizedBox(height: 14),
                              ...items.take(3).map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Text(item['emoji']?.toString() ?? '🛒', style: const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            '${item['name']} x${item['quantity']}',
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  )),
                              if (items.length > 3)
                                Text('+ ${items.length - 3} more item${items.length - 3 == 1 ? '' : 's'}',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textMuted),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      order['address']?.toString() ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                    ),
                                  ),
                                  Text(
                                    '₹${order['total']}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primaryDark),
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
