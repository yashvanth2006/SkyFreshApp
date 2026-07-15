import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';

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
                  'Reach our support team for order issues, delivery help, or account questions.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _ContactTile(
            icon: Icons.phone_rounded,
            title: 'Call Support',
            subtitle: '+91 88706 82988',
            onTap: () {},
          ),
          _ContactTile(
            icon: Icons.email_outlined,
            title: 'Email Us',
            subtitle: 'support@skyfresh.com',
            onTap: () {},
          ),
          _ContactTile(
            icon: Icons.access_time_rounded,
            title: 'Support Hours',
            subtitle: 'Mon – Sat, 9:00 AM – 8:00 PM',
            onTap: null,
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
