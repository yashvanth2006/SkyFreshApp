import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/widgets/premium_image.dart';


// Helper for readable status
String formatOrderStatus(String status) {
  return status.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}

// Helper for relative time
String formatRelativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
  return 'Just now';
}

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
        backgroundColor: AppTheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('My Orders', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryDark,
        onRefresh: _loadOrders,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryDark, strokeWidth: 3))
            : _orders.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                color: AppTheme.surfaceMuted,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, size: 56, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 24),
                            const Text('No orders yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: AppTheme.textMain)),
                            const SizedBox(height: 8),
                            const Text('Your order history will appear here', style: TextStyle(color: AppTheme.textMuted, fontSize: 15, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    itemCount: _orders.length,
                    itemBuilder: (_, i) {
                      final order = _orders[i];
                      final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
                      final status = order['status']?.toString() ?? 'placed';
                      final createdAt = DateTime.tryParse(order['createdAt']?.toString() ?? '') ?? DateTime.now();
                      final orderId = order['_id']?.toString() ?? '';
                      final shortId = orderId.length > 6 ? orderId.substring(orderId.length - 6).toUpperCase() : orderId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [AppTheme.cardShadow],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Order #$shortId', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textMain)),
                                      const SizedBox(height: 4),
                                      Text(formatRelativeTime(createdAt), style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      formatOrderStatus(status),
                                      style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w800, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...items.take(3).map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44, height: 44,
                                          decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(12)),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: PremiumImage(
                                              imageUrl: item['image']?.toString(),
                                              fallbackUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=400&auto=format&fit=crop',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            '${item['name']} x${item['quantity']}',
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.textMain),
                                          ),
                                        ),
                                        Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textMain)),
                                      ],
                                    ),
                                  )),
                              if (items.length > 3)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text('+ ${items.length - 3} more item${items.length - 3 == 1 ? '' : 's'}',
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.textMuted),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      order['shippingAddress']?.toString() ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '₹${order['totalAmount']}',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.primaryDark),
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