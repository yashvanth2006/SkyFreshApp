import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/cart_provider.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/models/user_profile.dart';
import 'package:skyfresh/screens/my_orders_screen.dart';
import 'package:skyfresh/screens/my_addresses_screen.dart';
import 'package:skyfresh/screens/help_support_screen.dart';
import 'package:skyfresh/screens/login_screen.dart';
import 'package:skyfresh/screens/ai_screen.dart';
import 'package:skyfresh/services/notification_service.dart';
import 'cart_screen.dart';
import 'notifications_screen.dart';

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
  int _notifCount = 0;
  
  String _search = '';
  Timer? _debounce;
  // FIXED: Added persistent controller to prevent memory leaks in the build method
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  final List<Map<String, String>> _categories = [
    {'name': 'All',        'icon': '🛒'},
    {'name': 'Fruits',     'icon': '🍎'},
    {'name': 'Juices',     'icon': '🥤'},
    {'name': 'Fresh Cuts', 'icon': '🍉'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchDynamicProducts();
    _initializeNotifications();
    _fetchNotificationCount();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose(); // FIXED: Proper cleanup
    super.dispose();
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

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService().initialize();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _fetchNotificationCount() async {
    try {
      final notifications = await ApiService.getNotifications();
      if (mounted) {
        setState(() {
          _notifCount = notifications.where((n) => n['unread'] == true).length;
        });
      }
    } catch (e) {
      print('Error fetching notification count: $e');
    }
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

  Future<void> _fetchDynamicProducts() async {
    setState(() => _loading = true);
    
    final categoryName = _categories[_selectedCategory]['name'];
    final products = await ApiService.getProducts(
      search: _search, 
      category: categoryName
    );
    
    if (!mounted) return;

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

  void _onSearchChanged(String query) {
    setState(() => _search = query);
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchDynamicProducts();
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
        onAdd: (weight) {
          cart.addItem(product, weight: weight);
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
      const AiScreen(),
      const NotificationsScreen(),
      _buildProfile(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: screens[_currentTab],
      bottomNavigationBar: _buildBottomNav(cart),
    );
  }

  Widget _buildBottomNav(CartProvider cart) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _bottomNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
              _bottomNavItem(
                icon: Icons.shopping_bag_rounded,
                label: 'Cart',
                index: 1,
                badge: cart.totalItems > 0 ? '${cart.totalItems}' : null,
              ),
              _bottomNavAiItem(),
              _bottomNavItem(
                icon: Icons.notifications_rounded,
                label: 'Alerts',
                index: 3,
                badge: _notifCount > 0 ? '$_notifCount' : null,
              ),
              _bottomNavItem(icon: Icons.person_rounded, label: 'Profile', index: 4),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabTap(int index) {
    setState(() => _currentTab = index);
    if (index == 4) _loadProfile();
  }

  Widget _bottomNavItem({
    required IconData icon,
    required String label,
    required int index,
    String? badge,
  }) {
    final selected = _currentTab == index;
    final color = selected ? AppTheme.primary : AppTheme.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 24),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.surface, width: 1.5),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavAiItem() {
    final selected = _currentTab == 2;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTap(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -8),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: selected ? AppTheme.greenGradient : const LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(selected ? 0.45 : 0.3),
                      blurRadius: selected ? 16 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: selected ? Colors.white : Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: selected ? 26 : 24,
                ),
              ),
            ),
            const SizedBox(height: 0),
            Text(
              'AI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: selected ? AppTheme.primaryDark : AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context, CartProvider cart) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: _fetchDynamicProducts,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
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
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [AppTheme.cardShadow.copyWith(blurRadius: 10, offset: const Offset(0, 4))],
                            border: Border.all(color: AppTheme.surfaceLight),
                          ),
                          child: const Center(
                            child: Text('🌿', style: TextStyle(fontSize: 22))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [AppTheme.cardShadow],
                        border: Border.all(color: AppTheme.border.withOpacity(0.4)),
                      ),
                      child: TextField(
                        onChanged: _onSearchChanged,
                        controller: _searchController,
                        style: const TextStyle(fontSize: 15, color: AppTheme.textMain, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Search premium fruits...',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 15, fontWeight: FontWeight.w500),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted),
                          suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                  FocusScope.of(context).unfocus();
                                },
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: AppTheme.greenGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryDark.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10, bottom: -20,
                        child: Opacity(
                          opacity: 0.15,
                          child: const Text('🍏', style: TextStyle(fontSize: 140)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Premium Freshness',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3, color: Colors.white)),
                            const SizedBox(height: 6),
                            const Text('Get 20% off on exotic fruits',
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.surface.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                padding: const EdgeInsets.fromLTRB(20, 28, 0, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categories',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800,
                          letterSpacing: -0.3, color: AppTheme.textMain)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (_, i) {
                          final selected = i == _selectedCategory;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedCategory = i);
                              _fetchDynamicProducts();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? AppTheme.primary : AppTheme.surface,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: selected ? AppTheme.primary : AppTheme.border.withOpacity(0.6)),
                                boxShadow: selected ? [
                                  BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                                ] : [],
                              ),
                              child: Row(children: [
                                if (selected) ...[
                                  Text(_categories[i]['icon']!, style: const TextStyle(fontSize: 15)),
                                  const SizedBox(width: 6),
                                ],
                                Text(_categories[i]['name']!,
                                  style: TextStyle(
                                    fontSize: 14, fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Curated For You',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800,
                          letterSpacing: -0.3, color: AppTheme.textMain)),
                    Text('${_products.length} items',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            _loading
              ? SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const _ProductSkeleton(),
                      childCount: 4,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.72,
                    ),
                  ),
                )
              : _products.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Text('🔍', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            const Text('No items found',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final p = _products[i];
                          return _ProductCard(
                            product: p,
                            onAdd: () => context.read<CartProvider>().addItem(p),
                            onTap: () => _openProductSheet(p, context.read<CartProvider>()),
                          );
                        },
                        childCount: _products.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.72,
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
    final addressCount = _profile?.addresses.length ?? 0;

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _loadProfile,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              child: Column(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.greenGradient,
                      boxShadow: [
                        BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10)),
                      ],
                      border: Border.all(color: AppTheme.surface, width: 4),
                    ),
                    child: Center(
                      child: _profileLoading
                          ? const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                            )
                          : Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppTheme.textMain),
                        ),
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(phone, style: const TextStyle(color: AppTheme.textMuted, fontSize: 15, fontWeight: FontWeight.w500)),
                        ],
                      ],
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceMuted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('SKYfresh Premium Member', style: TextStyle(color: AppTheme.primaryDark, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard('Orders', '$orderCount', Icons.shopping_bag_rounded),
                  const SizedBox(width: 16),
                  _buildStatCard('Addresses', '$addressCount', Icons.location_on_rounded),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('Account', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.3)),
                const SizedBox(height: 12),
                _buildMenuSection([
                  _profileTile(Icons.shopping_bag_outlined, 'My Orders', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()))),
                  _profileTile(Icons.location_on_outlined, 'My Addresses', onTap: _openAddresses),
                ]),
                const SizedBox(height: 28),
                const Text('Support & Settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.3)),
                const SizedBox(height: 12),
                _buildMenuSection([
                  _profileTile(Icons.help_outline_rounded, 'Help & Support', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
                  _profileTile(Icons.logout_rounded, 'Logout', isDestructive: true, onTap: _logout, showBorder: false),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [AppTheme.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.surfaceMuted, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: AppTheme.primaryDark, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.textMain)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        children: children,
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

  Widget _profileTile(
    IconData icon,
    String label, {
    bool isDestructive = false,
    VoidCallback? onTap,
    bool showBorder = true,
  }) {
    final color = isDestructive ? Colors.redAccent : AppTheme.textMain;
    return Container(
      decoration: BoxDecoration(
        border: showBorder ? const Border(bottom: BorderSide(color: AppTheme.surfaceLight, width: 1.5)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: showBorder ? BorderRadius.zero : const BorderRadius.vertical(bottom: Radius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDestructive ? Colors.redAccent.withOpacity(0.08) : AppTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: isDestructive ? Colors.redAccent : AppTheme.primaryDark, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
                ),
                Icon(Icons.chevron_right_rounded, color: isDestructive ? Colors.redAccent.withOpacity(0.4) : AppTheme.textMuted.withOpacity(0.5)),
              ],
            ),
          ),
        ),
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
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [AppTheme.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceMuted,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: product['image'] != null && product['image'].toString().isNotEmpty
                        ? Image.network(
                            product['image'],
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(product['emoji'], style: const TextStyle(fontSize: 50)),
                          ),
                    ),
                  ),
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco_rounded, size: 12, color: AppTheme.primaryDark),
                          SizedBox(width: 4),
                          Text('Fresh', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(product['unit'],
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product['price'],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
                      GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
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
    );
  }
}

class _ProductSkeleton extends StatelessWidget {
  const _ProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceLight,
      highlightColor: Colors.white.withOpacity(0.5),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
        ),
      ),
    );
  }
}

class _ProductDetailSheet extends StatefulWidget {
  final Map<String, dynamic> product;
  final ValueChanged<String> onAdd;
  const _ProductDetailSheet({required this.product, required this.onAdd});

  @override
  State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  String _weight = '250g';

  int _gramsIn(String value) {
    final match = RegExp(r'(\d+)\s*g', caseSensitive: false).firstMatch(value);
    if (match != null) return int.parse(match.group(1)!);
    final kg = RegExp(r'(\d+)\s*kg', caseSensitive: false).firstMatch(value);
    return kg == null ? 0 : int.parse(kg.group(1)!) * 1000;
  }

  String get _calculatedPrice {
    final product = widget.product;
    final supportsWeight = product['category'] == 'Fruits';
    if (!supportsWeight) return product['price'];

    final baseWeight = _gramsIn(product['unit'].toString());
    final requestedWeight = _gramsIn(_weight);
    final basePrice = int.parse(product['price'].toString().replaceAll(RegExp(r'[^0-9]'), ''));

    if (baseWeight > 0 && requestedWeight > 0) {
      final price = (basePrice * requestedWeight / baseWeight).round();
      return '₹$price';
    }
    return product['price'];
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final supportsWeight = product['category'] == 'Fruits';
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
                    Text('${product['category']} • ${supportsWeight ? _weight : product['unit']}',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Text(_calculatedPrice,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primaryLight)),
            ],
          ),
          const SizedBox(height: 24),
          if (supportsWeight) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Choose quantity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['250g', '500g', '750g', '1kg'].map((weight) {
                final selected = _weight == weight;
                return ChoiceChip(
                  label: Text(weight),
                  selected: selected,
                  onSelected: (_) => setState(() => _weight = weight),
                  selectedColor: AppTheme.primary.withOpacity(0.18),
                  labelStyle: TextStyle(color: selected ? AppTheme.primaryDark : AppTheme.textMuted, fontWeight: FontWeight.w700),
                  side: BorderSide(color: selected ? AppTheme.primary : AppTheme.border),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          GestureDetector(
            onTap: () => widget.onAdd(supportsWeight ? _weight : product['unit'].toString()),
            child: Container(
              width: double.infinity, height: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.greenGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))
                ],
              ),
              child: Center(
                child: Text(supportsWeight ? 'Add $_weight to Cart' : 'Add to Cart',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}