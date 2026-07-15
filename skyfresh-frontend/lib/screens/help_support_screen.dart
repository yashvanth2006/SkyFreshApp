import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/shop_info.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    {
      'q': 'How do I track my order?',
      'a': 'Go to Profile → My Orders to see live status updates for every order you place.',
    },
    {
      'q': 'Can I change my delivery address?',
      'a': 'Yes. Open Profile → My Addresses to add, edit default, or remove saved addresses before checkout.',
    },
    {
      'q': 'What payment methods are supported?',
      'a': 'Cash on Delivery is available now. Online payments will be added soon.',
    },
    {
      'q': 'How fresh are the products?',
      'a': 'All SKYfresh items are sourced daily and quality-checked before dispatch.',
    },
  ];

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open this link on your device')),
    );
  }

  Future<void> _launch(BuildContext context, Future<bool> Function() action) async {
    final ok = await action();
    if (!context.mounted) return;
    if (!ok) _showLaunchError(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.greenGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [AppTheme.cardShadow.copyWith(blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('We\'re here to help 🌿', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text(
                  'Reach our team for order help, delivery questions, or to visit our store.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Our Store', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: AppTheme.primaryDark),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        ShopInfo.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Fresh fruits and juices delivered from our store.',
                  style: TextStyle(color: AppTheme.textMuted, height: 1.45),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 18, color: AppTheme.primaryDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ShopInfo.openingHours,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textMain),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Contact Us', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _ContactTile(
            icon: Icons.phone_rounded,
            title: 'Primary Phone',
            subtitle: ShopInfo.primaryPhoneDisplay,
            onTap: () => _launch(context, ShopInfo.callPrimary),
          ),
          _ContactTile(
            icon: Icons.phone_in_talk_rounded,
            title: 'Secondary Phone',
            subtitle: ShopInfo.secondaryPhoneDisplay,
            onTap: () => _launch(context, ShopInfo.callSecondary),
          ),
          _ContactTile(
            icon: Icons.chat_rounded,
            title: 'WhatsApp',
            subtitle: ShopInfo.primaryPhoneDisplay,
            onTap: () => _launch(context, ShopInfo.openWhatsApp),
          ),
          _ContactTile(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: ShopInfo.email,
            onTap: () => _launch(context, ShopInfo.sendEmail),
          ),
          _ContactTile(
            icon: Icons.location_on_rounded,
            title: 'Store Location',
            subtitle: 'Open in Google Maps',
            onTap: () => _launch(context, ShopInfo.openMaps),
          ),
          const SizedBox(height: 24),
          const Text('Frequently Asked Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(faq['q']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(faq['a']!, style: const TextStyle(color: AppTheme.textMuted, height: 1.45)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryDark),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted)),
        trailing: onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted) : null,
      ),
    );
  }
}
