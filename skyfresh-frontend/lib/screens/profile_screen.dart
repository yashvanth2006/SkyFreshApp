import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onLogout;
  final Future<void> Function()? onRefresh;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    this.onRefresh,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserProfile _user;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
    final profile = await ApiService.getProfile();
    if (!mounted) return;
    setState(() {
      if (profile != null) _user = profile;
      _refreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 210,
              pinned: true,
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                background: Container(
                  decoration: const BoxDecoration(gradient: AppTheme.greenGradient),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                      child: Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.white.withOpacity(0.35), width: 2),
                            ),
                            child: Center(
                              child: Text(
                                _user.name.isNotEmpty ? _user.name[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _user.name,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(_user.phone, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'SKYfresh Premium Member',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_refreshing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
                    ),
                  Row(
                    children: [
                      _ProfileStat(label: 'Orders', value: '${_user.orderCount}'),
                      const SizedBox(width: 12),
                      _ProfileStat(label: 'Reviews', value: '${_user.reviewCount}'),
                      const SizedBox(width: 12),
                      _ProfileStat(label: 'Joined', value: _user.formattedJoinDate, compact: true),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _SectionTitle('Account Details'),
                  const SizedBox(height: 12),
                  _InfoTile(label: 'Full Name', value: _user.name, icon: Icons.person_outline_rounded),
                  _InfoTile(label: 'Phone Number', value: _user.phone, icon: Icons.phone_rounded),
                  _InfoTile(label: 'Member Since', value: _user.formattedJoinDate, icon: Icons.calendar_month_rounded),
                  _InfoTile(
                    label: 'Default Address',
                    value: _user.defaultAddress ?? 'No address saved yet',
                    subtitle: _user.defaultAddress == null ? 'Add one from My Addresses or during checkout' : null,
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: widget.onLogout,
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.2),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final bool compact;

  const _ProfileStat({required this.label, required this.value, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
          boxShadow: [AppTheme.cardShadow.copyWith(blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 13 : 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryDark, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textMain)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
