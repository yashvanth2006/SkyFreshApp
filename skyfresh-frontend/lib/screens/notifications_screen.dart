import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/widgets/animated_pressable.dart';



class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _loading = true);
    final notifications = await ApiService.getNotifications();
    
    if (!mounted) return;
    setState(() {
      _notifications = notifications.map((n) {
        return {
          '_id': n['_id'],
          'title': n['title'] ?? 'Notification',
          'body': n['body'] ?? '',
          'time': _formatTime(n['createdAt']),
          'color': _hexToInt(n['color'] ?? '#DCFCE7'),
          'unread': n['unread'] ?? false,
        };
      }).toList();
      _loading = false;
    });
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return 'Just now';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 2) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays} days ago';
    } catch (e) {
      return 'Just now';
    }
  }

  int _hexToInt(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }

  int get _unreadCount => _notifications.where((n) => n['unread'] == true).length;



  Future<void> _markRead(int index) async {
    if (_notifications[index]['unread'] == true) {
      setState(() => _notifications[index]['unread'] = false);
      await ApiService.markNotificationRead(_notifications[index]['_id']);
    }
  }

  Future<void> _dismiss(int index) async {
    final id = _notifications[index]['_id'];
    setState(() => _notifications.removeAt(index));
    if (id != null) {
      await ApiService.deleteNotification(id);
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
        title: const Text('Notifications', style: TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$_unreadCount new', style: const TextStyle(color: AppTheme.primaryDark, fontSize: 13, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryDark, strokeWidth: 3))
        : _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: const BoxDecoration(color: AppTheme.surfaceMuted, shape: BoxShape.circle),
                    child: const Center(child: Icon(Icons.notifications_off_outlined, size: 56, color: AppTheme.textMuted)),
                  ),
                  const SizedBox(height: 24),
                  const Text('No notifications yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: AppTheme.textMain)),
                  const SizedBox(height: 8),
                  const Text('We\'ll let you know when there\'s news', style: TextStyle(color: AppTheme.textMuted, fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _notifications.length,
            itemBuilder: (_, i) {
              final n = _notifications[i];
              return Dismissible(
                key: ValueKey(n['title'] + n['time']),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _dismiss(i),
                background: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.only(right: 24),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                ),
                child: AnimatedPressable(
                  onTap: () => _markRead(i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: n['unread'] == true ? AppTheme.primaryLight.withValues(alpha: 0.15) : AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: n['unread'] == true ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.border.withValues(alpha: 0.5),
                        width: n['unread'] == true ? 2 : 1,
                      ),
                      boxShadow: [AppTheme.cardShadow],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: Color(n['color']).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(child: Icon(Icons.notifications_active_rounded, color: Color(n['color']), size: 26)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(n['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                                  ),
                                  if (n['unread'] == true)
                                    Container(
                                      width: 10, height: 10,
                                      margin: const EdgeInsets.only(left: 8),
                                      decoration: const BoxDecoration(color: AppTheme.primaryDark, shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(n['body'], style: const TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.4, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Text(n['time'], style: const TextStyle(fontSize: 12, color: AppTheme.primaryDark, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}