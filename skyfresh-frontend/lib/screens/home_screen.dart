import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/cart_provider.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/models/user_profile.dart';
import 'package:skyfresh/screens/profile_screen.dart';
import 'package:skyfresh/screens/my_orders_screen.dart';
import 'package:skyfresh/screens/my_addresses_screen.dart';
import 'package:skyfresh/screens/my_reviews_screen.dart';
import 'package:skyfresh/screens/help_support_screen.dart';
import 'package:skyfresh/screens/login_screen.dart';
import 'cart_screen.dart';
import 'notifications_screen.dart';
import 'reviews_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'there';
  UserProfile? _profile;
  bool _profileLoading = true;
  bool _profileError = false;
  int _selectedCategory = 0;
  int _currentTab = 0;
  final int _notifCount = 5;
  String _search = '';
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  final List<Map<String, String>> _categories = [
    {'name': 'All',        'icon': '🛒'},
    {'name': 'Fruits',     'icon': '🍎'},
    {'name': 'Juices',     'icon': '🥤'},
    {'name': 'Fresh Cuts', 'icon': '🍉'},
  ];

  List<Map<String, dynamic>> get _filtered {
    var list = _products;
    if (_selectedCategory != 0) {
      final cat = _categories[_selectedCategory]['name'];
      list = list.where((p) => p['category'] == cat).toList();
    }
    if (_search.trim().isNotEmpty) {
      final q = _search.trim().toLowerCase();
      list = list.where((p) =>
          p['name'].toString().toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadProducts();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('userName') ?? 'there';
    setState(() => _userName = storedName);
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _profileLoading = true;
      _profileError = false;
    });

    final profile = await ApiService.getProfile();
    if (!mounted) return;

    setState(() {
      _profile = profile;
      _profileLoading = false;
      _profileError = profile == null;
      if (profile != null) {
        _userName = profile.name;
      }
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final products = await ApiService.getProducts();
    setState(() {
      _products = products.map((p) => {
       'name':     p['name'],
       'price':    '₹${p['price']}',
       'unit':     p['unit'],
       'emoji':    p['emoji'],
       'category': p['category'],
       'color':    _hexToInt(p['color'] ?? '#DCFCE7'),
       '_id':      p['_id'],
       'image':    p['image'] ?? '',
      }).toList();
      _loading = false;
    });
  }

  int _hexToInt(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }

  void _openProductSheet(Map<String, dynamic> product, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ProductDetailSheet(
        product: product,
        onAdd: () {
          cart.addItem(product);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.primaryDark,
              duration: const Duration(milliseconds: 900),
              content: Text('${product['name']} added to cart', style: const TextStyle(color: Colors.white)),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    final List<Widget> screens = [
      _buildHome(context, cart),
      const CartScreen(),
      const NotificationsScreen(),
      const ReviewsScreen(),
      _buildProfile(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: screens[_currentTab],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _currentTab,
            onTap: (i) {
              setState(() => _currentTab = i);
              if (i == 4) _loadProfile();
            },
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.textMuted,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_bag_rounded),
                    if (cart.totalItems > 0)
                      Positioned(
                        right: -6, top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.surface, width: 1.5),
                          ),
                          child: Text('${cart.totalItems}',
                            style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_rounded),
                    if (_notifCount > 0)
                      Positioned(
                        right: -6, top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.surface, width: 1.5),
                          ),
                          child: Text('$_notifCount',
                            style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
                label: 'Alerts',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.star_rounded), label: 'Reviews'),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context, CartProvider cart) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: _loadProducts,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hey, $_userName 👋',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5, color: AppTheme.textMain)),
                            const SizedBox(height: 4),
                            const Text('Premium fresh picks, for you',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Center(
                            child: Text('🌿', style: TextStyle(fontSize: 24))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => _search = v),
                        style: const TextStyle(fontSize: 15, color: AppTheme.textMain),
                        decoration: InputDecoration(
                          hintText: 'Search premium fruits...',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                          suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 20),
                                onPressed: () => setState(() => _search = ''),
                              )
                            : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Container(
                  width: double.infinity,
                  height: 170,
                  decoration: BoxDecoration(
                    gradient: AppTheme.greenGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryDark.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10, bottom: -10,
                        child: Opacity(
                          opacity: 0.15,
                          child: const Text('🍎', style: TextStyle(fontSize: 120)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Premium Freshness',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3, color: Colors.white)),
                            const SizedBox(height: 6),
                            const Text('Get 20% off on exotic fruits',
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Text('Order Now',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categories',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800,
                          letterSpacing: -0.3, color: AppTheme.textMain)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 46,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (_, i) {
                          final selected = i == _selectedCategory;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? AppTheme.primary : AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
                                boxShadow: selected ? [
                                  BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                                ] : [],
                              ),
                              child: Row(children: [
                                Text(_categories[i]['icon']!, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(_categories[i]['name']!,
                                  style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: selected ? Colors.white : AppTheme.textMuted)),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Curated For You',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800,
                          letterSpacing: -0.3, color: AppTheme.textMain)),
                    Text('${_filtered.length} items',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            _loading
              ? SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const _ProductSkeleton(),
                      childCount: 4,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75,
                    ),
                  ),
                )
              : _filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Text('🔍', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            const Text('No items found',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final p = _filtered[i];
                          return _ProductCard(
                            product: p,
                            onAdd: () => context.read<CartProvider>().addItem(p),
                            onTap: () => _openProductSheet(p, context.read<CartProvider>()),
                          );
                        },
                        childCount: _filtered.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    final name = _profile?.name ?? _userName;
    final phone = _profile?.phone ?? '';
    final orderCount = _profile?.orderCount ?? 0;
    final reviewCount = _profile?.reviewCount ?? 0;
    final addressCount = _profile?.addresses.length ?? 0;

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _loadProfile,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
              child: Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      gradient: AppTheme.greenGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Center(
                      child: _profileLoading
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_profileError && !_profileLoading)
                    Column(
                      children: [
                        const Text('Unable to load profile', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextButton(onPressed: _loadProfile, child: const Text('Retry')),
                      ],
                    )
                  else if (!_profileLoading)
                    Column(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: AppTheme.textMain),
                        ),
                        const SizedBox(height: 4),
                        Text(phone, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('SKYfresh Premium Member', style: TextStyle(color: AppTheme.primaryDark, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  if (_profile != null && !_profileLoading) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _ProfileQuickStat(label: 'Orders', value: '$orderCount'),
                        const SizedBox(width: 10),
                        _ProfileQuickStat(label: 'Reviews', value: '$reviewCount'),
                        const SizedBox(width: 10),
                        _ProfileQuickStat(label: 'Addresses', value: '$addressCount'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _profileTile(
                  Icons.shopping_bag_rounded,
                  'My Orders',
                  subtitle: orderCount == 0 ? 'No orders yet' : '$orderCount order${orderCount == 1 ? '' : 's'}',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                ),
                _profileTile(
                  Icons.location_on_rounded,
                  'My Addresses',
                  subtitle: addressCount == 0 ? 'Add a delivery address' : '$addressCount saved',
                  onTap: _openAddresses,
                ),
                _profileTile(
                  Icons.star_rounded,
                  'My Reviews',
                  subtitle: reviewCount == 0 ? 'Share your experience' : '$reviewCount review${reviewCount == 1 ? '' : 's'}',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReviewsScreen())),
                ),
                _profileTile(
                  Icons.help_outline_rounded,
                  'Help & Support',
                  subtitle: 'FAQs and contact support',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                ),
                _profileTile(
                  Icons.person_rounded,
                  'View Profile',
                  subtitle: 'Account details and settings',
                  onTap: _openProfilePage,
                ),
                _profileTile(Icons.logout_rounded, 'Logout', isDestructive: true, onTap: _logout),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddresses() async {
    if (_profile == null) {
      await _loadProfile();
    }
    if (!mounted) return;
    if (_profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait while profile loads')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyAddressesScreen(
          profile: _profile!,
          onProfileUpdated: (profile) {
            if (mounted) setState(() => _profile = profile);
          },
        ),
      ),
    );
    if (mounted) _loadProfile();
  }

  void _openProfilePage() {
    if (_profile == null && !_profileLoading) {
      _loadProfile().then((_) {
        if (!mounted) return;
        _pushProfileScreen();
      });
      return;
    }

    _pushProfileScreen();
  }

  void _pushProfileScreen() {
    final profile = _profile ?? UserProfile(
      id: 'unknown',
      name: _userName,
      phone: '',
      joinedAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          user: profile,
          onLogout: _logout,
          onRefresh: _loadProfile,
        ),
      ),
    );
  }

  Widget _profileTile(
    IconData icon,
    String label, {
    String? subtitle,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final color = isDestructive ? Colors.redAccent : AppTheme.textMain;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [AppTheme.cardShadow.copyWith(blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDestructive ? Colors.redAccent.withOpacity(0.1) : AppTheme.primaryLight.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500))
            : null,
        trailing: Icon(Icons.chevron_right_rounded, color: isDestructive ? Colors.redAccent.withOpacity(0.5) : AppTheme.textMuted),
      ),
    );
  }
}

class _ProfileQuickStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileQuickStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAdd;
  final VoidCallback onTap;
  const _ProductCard({required this.product, required this.onAdd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: product['image'] != null && product['image'].toString().isNotEmpty
                  ? Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Color(product['color']).withOpacity(0.1),
                      child: Center(
                        child: Text(product['emoji'], style: const TextStyle(fontSize: 50)),
                      ),
                    ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                    )
                  ),
                ),
              ),
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_rounded, size: 12, color: AppTheme.primary),
                      SizedBox(width: 4),
                      Text('Fresh', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12, left: 12, right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'],
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(product['unit'],
                      style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(product['price'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryLight)),
                        GestureDetector(
                          onTap: onAdd,
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductSkeleton extends StatefulWidget {
  const _ProductSkeleton();
  @override
  State<_ProductSkeleton> createState() => _ProductSkeletonState();
}

class _ProductSkeletonState extends State<_ProductSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final op = 0.4 + (_c.value * 0.3);
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight.withOpacity(op),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border.withOpacity(op)),
          ),
        );
      },
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAdd;
  const _ProductDetailSheet({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, height: 5,
            decoration: BoxDecoration(
              color: AppTheme.border, borderRadius: BorderRadius.circular(5)),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: double.infinity, height: 220,
              color: AppTheme.surfaceLight,
              child: product['image'] != null && product['image'].toString().isNotEmpty
                ? Image.network(product['image'], fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(product['emoji'], style: const TextStyle(fontSize: 72))))
                : Center(child: Text(product['emoji'], style: const TextStyle(fontSize: 72))),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                          letterSpacing: -0.4, color: AppTheme.textMain)),
                    const SizedBox(height: 4),
                    Text('${product['category']} • ${product['unit']}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Text(product['price'],
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primaryLight)),
            ],
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: double.infinity, height: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.greenGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))
                ],
              ),
              child: const Center(
                child: Text('Add to Cart',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}