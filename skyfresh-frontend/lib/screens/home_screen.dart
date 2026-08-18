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
import 'package:skyfresh/widgets/premium_image.dart';
import 'package:skyfresh/widgets/animated_pressable.dart';
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

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All',        'icon': Icons.apps_rounded},
    {'name': 'Fruits',     'icon': Icons.eco_rounded},
    {'name': 'Juices',     'icon': Icons.local_drink_rounded},
    {'name': 'Fresh Cuts', 'icon': Icons.restaurant_menu_rounded},
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4)),
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
      child: AnimatedPressable(
        onTap: () => _onTabTap(index),
        scaleDown: 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: selected ? 20 : 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryLight.withValues(alpha: 0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: selected ? 26 : 24),
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
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
                      color: AppTheme.primary.withValues(alpha: selected ? 0.45 : 0.3),
                      blurRadius: selected ? 16 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: selected ? Colors.white : Colors.white.withValues(alpha: 0.5),
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
                        AnimatedPressable(
                          onTap: () => _onTabTap(4),
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [AppTheme.softShadow],
                              border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                            ),
                            child: Center(
                              child: Text(
                                _userName.isNotEmpty && _userName != 'there' ? _userName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [AppTheme.cardShadow],
                        border: Border.all(color: AppTheme.border.withValues(alpha: 0.4)),
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
                child: _PromoBanner(
                  onCategorySelected: (categoryIndex) {
                    setState(() => _selectedCategory = categoryIndex);
                    _fetchDynamicProducts();
                  },
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
                          return AnimatedPressable(
                            onTap: () {
                              setState(() => _selectedCategory = i);
                              _fetchDynamicProducts();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? AppTheme.primary : AppTheme.surface,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: selected ? AppTheme.primary : AppTheme.border.withValues(alpha: 0.6)),
                                boxShadow: selected ? [
                                  BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                                ] : [],
                              ),
                              child: Row(children: [
                                if (selected) ...[
                                  Icon(_categories[i]['icon'] as IconData, size: 18, color: Colors.white),
                                  const SizedBox(width: 8),
                                ],
                                Text(_categories[i]['name'] as String,
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
                            const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted),
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryLight.withValues(alpha: 0.3),
                        ),
                      ),
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.greenGradient,
                          boxShadow: [
                            BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 10)),
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
                    ],
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
                const Text('Account Actions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.3)),
                const SizedBox(height: 12),
                _profileTile(Icons.shopping_bag_outlined, 'My Orders', subtitle: 'Track your purchases', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()))),
                _profileTile(Icons.location_on_outlined, 'My Addresses', subtitle: 'Manage delivery spots', onTap: _openAddresses),
                const SizedBox(height: 28),
                const Text('Support & Settings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textMain, letterSpacing: -0.3)),
                const SizedBox(height: 12),
                _profileTile(Icons.help_outline_rounded, 'Help & Support', subtitle: 'Get assistance', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
                _profileTile(Icons.logout_rounded, 'Logout', subtitle: 'Sign out securely', isDestructive: true, onTap: _logout),
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
    String? subtitle,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final color = isDestructive ? Colors.redAccent : AppTheme.textMain;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedPressable(
        onTap: onTap ?? () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [AppTheme.softShadow],
            border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDestructive ? Colors.redAccent.withValues(alpha: 0.08) : AppTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: isDestructive ? Colors.redAccent : AppTheme.primaryDark, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textMuted)),
                    ]
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: isDestructive ? Colors.redAccent.withValues(alpha: 0.4) : AppTheme.primary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// Promotional banner data model
// ---------------------------------------------------------------------------
class _BannerSlide {
  final String title;
  final String description;
  final String supportingText;
  final String ctaLabel;
  final String imageUrl;
  final int categoryIndex; // maps to _HomeScreenState._categories index

  const _BannerSlide({
    required this.title,
    required this.description,
    required this.supportingText,
    required this.ctaLabel,
    required this.imageUrl,
    required this.categoryIndex,
  });
}

// ---------------------------------------------------------------------------
// Auto-sliding 16:9 promotional carousel
// ---------------------------------------------------------------------------
class _PromoBanner extends StatefulWidget {
  final ValueChanged<int> onCategorySelected;

  const _PromoBanner({required this.onCategorySelected});

  @override
  State<_PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<_PromoBanner> {
  // ---------------------------------------------------------------------------
  // Centralized banner data — easy to update or extend.
  // ---------------------------------------------------------------------------
  static const List<_BannerSlide> _slides = [
    _BannerSlide(
      title: 'Fresh Fruits',
      description: "Nature's goodness, handpicked fresh for you.",
      supportingText: 'Farm fresh  •  Naturally delicious',
      ctaLabel: 'Shop Fruits',
      imageUrl:
          'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=1470&auto=format&fit=crop',
      categoryIndex: 1, // Fruits
    ),
    _BannerSlide(
      title: 'Refreshing Juices',
      description: 'Pure. Refreshing. Made from real fruits.',
      supportingText: 'Freshly made  •  Naturally refreshing',
      ctaLabel: 'Explore Juices',
      imageUrl:
          'https://images.unsplash.com/photo-1546173159-315724a31696?q=80&w=1470&auto=format&fit=crop',
      categoryIndex: 2, // Juices
    ),
    _BannerSlide(
      title: 'Fresh Cuts',
      description: 'Cut fresh. Packed fresh. Ready to enjoy.',
      supportingText: 'Freshly prepared  •  Hygienically packed',
      ctaLabel: 'Explore Fresh Cuts',
      imageUrl:
          'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?q=80&w=1470&auto=format&fit=crop',
      categoryIndex: 3, // Fresh Cuts
    ),
  ];

  late final PageController _pageController;
  Timer? _autoTimer;
  int _currentPage = 0;

  // We use a large virtual page count for infinite looping.
  static const int _virtualPageCount = 30000;
  static const int _initialPage = 15000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _startAutoTimer();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int virtualPage) {
    setState(() => _currentPage = virtualPage % _slides.length);
  }

  void _onUserInteraction() {
    // Reset timer when user swipes manually
    _startAutoTimer();
  }

  void _selectSlideCategory(int slideIndex) {
    widget.onCategorySelected(_slides[slideIndex].categoryIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 16:9 banner ──────────────────────────────────────────────────────
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                // Detect manual drag and reset the auto-timer
                if (n is ScrollStartNotification &&
                    n.dragDetails != null) {
                  _onUserInteraction();
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _virtualPageCount,
                itemBuilder: (context, virtualIndex) {
                  final slide = _slides[virtualIndex % _slides.length];
                  return _BannerSlideWidget(
                    slide: slide,
                    onTap: () => _selectSlideCategory(
                        virtualIndex % _slides.length),
                  );
                },
              ),
            ),
          ),
        ),

        // ── Page dot indicators ───────────────────────────────────────────
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.primary
                    : AppTheme.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual slide widget — keeps the carousel builder clean
// ---------------------------------------------------------------------------
class _BannerSlideWidget extends StatelessWidget {
  final _BannerSlide slide;
  final VoidCallback onTap;

  const _BannerSlideWidget({required this.slide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──────────────────────────────────────────────
          Image.network(
            slide.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppTheme.primaryDark,
            ),
            loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              return Container(color: AppTheme.surfaceLight);
            },
          ),

          // ── Dark gradient overlay (left→right, heavier on left for text) ─
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryDark.withValues(alpha: 0.88),
                  AppTheme.primaryDark.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // ── Bottom vignette so indicators area doesn't clip text ──────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.25),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── Text + CTA content ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 100, 18),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  slide.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Colors.white,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  slide.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Supporting text
                Text(
                  slide.supportingText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // CTA button
                _CtaButton(
                  label: slide.ctaLabel,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable CTA button with press animation
// ---------------------------------------------------------------------------
class _CtaButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _CtaButton({required this.label, required this.onTap});

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 130),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.1,
            ),
          ),
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
    return AnimatedPressable(
      onTap: onTap,
      scaleDown: 0.98,
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
                    decoration: const BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: PremiumImage(
                        imageUrl: product['image']?.toString(),
                        fallbackUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=400&auto=format&fit=crop',
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
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
                      AnimatedPressable(
                        onTap: onAdd,
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))],
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
      highlightColor: Colors.white.withValues(alpha: 0.5),
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
              child: PremiumImage(
                imageUrl: product['image']?.toString(),
                fallbackUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=800&auto=format&fit=crop',
              ),
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
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.primaryDark)),
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
                  selectedColor: AppTheme.primary.withValues(alpha: 0.18),
                  labelStyle: TextStyle(color: selected ? AppTheme.primaryDark : AppTheme.textMuted, fontWeight: FontWeight.w700),
                  side: BorderSide(color: selected ? AppTheme.primary : AppTheme.border),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
          AnimatedPressable(
            onTap: () => widget.onAdd(supportsWeight ? _weight : product['unit'].toString()),
            child: Container(
              width: double.infinity, height: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.greenGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))
                ],
              ),
              child: Center(
                child: Text(supportsWeight ? 'Add $_weight to Cart' : 'Add to Cart',
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}