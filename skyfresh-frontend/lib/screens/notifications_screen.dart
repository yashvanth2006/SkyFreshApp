import 'package:flutter/material.dart';

class _Brand {
  static const Color dark = Color(0xFF0F172A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFF22C55E);
  static const Color muted = Color(0xFF64748B);
  static const Color bg = Color(0xFFF6FAF7);

  static const LinearGradient gradient = LinearGradient(
    colors: [primaryDark, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Order Delivered! 🎉',
      'body': 'Your order #001 has been delivered. Enjoy your fresh fruits!',
      'time': '2 mins ago',
      'icon': '✅',
      'color': 0xFFDCFCE7,
      'unread': true,
    },
    {
      'title': 'Order Confirmed 📦',
      'body': 'Your order #002 has been confirmed and is being prepared.',
      'time': '1 hour ago',
      'icon': '📦',
      'color': 0xFFDBEAFE,
      'unread': true,
    },
    {
      'title': 'Special Offer! 🥭',
      'body': 'Get 20% off on all mango products today only!',
      'time': '3 hours ago',
      'icon': '🎁',
      'color': 0xFFFFF3CD,
      'unread': true,
    },
    {
      'title': 'Out for Delivery 🛵',
      'body': 'Your order is out for delivery. Expected in 30 minutes.',
      'time': 'Yesterday',
      'icon': '🛵',
      'color': 0xFFFFEDD5,
      'unread': false,
    },
    {
      'title': 'New Arrivals 🍍',
      'body': 'Fresh pineapples and kiwis are now available on SKYfresh!',
      'time': '2 days ago',
      'icon': '🌿',
      'color': 0xFFEDE9FE,
      'unread': false,
    },
  ];

  int get _unreadCount => _notifications.where((n) => n['unread'] == true).length;

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['unread'] = false;
      }
    });
  }

  void _dismiss(int index) {
    setState(() => _notifications.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Brand.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: _Brand.gradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifications 🔔',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                        letterSpacing: -0.5, color: Colors.white)),
                  Row(
                    children: [
                      if (_unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20)),
                          child: Text('$_unreadCount new',
                            style: const TextStyle(color: Colors.white,
                                fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      GestureDetector(
                        onTap: _markAllRead,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                          child: const Text('Mark all read',
                            style: TextStyle(color: _Brand.primaryDark,
                                fontSize: 11.5, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔕', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 14),
                        const Text('No notifications yet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                              color: _Brand.dark)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (_, i) {
                      final n = _notifications[i];
                      return Dismissible(
                        key: ValueKey(n['title'] + n['time']),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _dismiss(i),
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(18)),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => n['unread'] = false),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: n['unread'] == true
                                ? Border.all(color: const Color(0xFFBBF7D0), width: 1.4)
                                : null,
                              boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  color: Color(n['color']),
                                  borderRadius: BorderRadius.circular(15)),
                                child: Center(
                                  child: Text(n['icon'],
                                    style: const TextStyle(fontSize: 24))),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(n['title'],
                                      style: const TextStyle(fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.1,
                                          color: _Brand.dark)),
                                  ),
                                  if (n['unread'] == true)
                                    Container(
                                      width: 8, height: 8,
                                      decoration: const BoxDecoration(
                                        color: _Brand.primaryDark, shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(n['body'],
                                    style: const TextStyle(fontSize: 12.5,
                                        color: _Brand.muted, height: 1.3)),
                                  const SizedBox(height: 6),
                                  Text(n['time'],
                                    style: const TextStyle(fontSize: 11,
                                        color: _Brand.primaryDark,
                                        fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}