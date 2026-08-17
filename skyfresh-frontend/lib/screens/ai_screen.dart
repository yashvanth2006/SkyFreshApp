import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/cart_provider.dart';
import 'package:provider/provider.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _question = TextEditingController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage('Hi! I\'m your Smart Nutritionist. How are you feeling today? (e.g., "I need a detox" or "I have a cold")', false),
  ];
  bool _isLoading = false;
  List<Map<String, dynamic>> _recommendedProducts = [];

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  void _ask() async {
    final question = _question.text.trim();
    if (question.isEmpty) return;
    
    setState(() {
      _messages.add(_ChatMessage(question, true));
      _isLoading = true;
      _recommendedProducts = [];
      _question.clear();
    });

    final response = await ApiService.askNutritionist(question);
    
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
      if (response['success'] == true) {
        _messages.add(_ChatMessage(response['message'], false));
        _recommendedProducts = List<Map<String, dynamic>>.from(response['recommendedProducts'] ?? []);
      } else {
        _messages.add(_ChatMessage('Sorry, I couldn\'t process your request. Please try again.', false));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryDark),
            SizedBox(width: 8),
            Text('Smart Nutritionist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Recommended Products Section
            if (_recommendedProducts.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recommended for you', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textMuted)),
                ),
              ),
              SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _recommendedProducts.length,
                  itemBuilder: (_, index) {
                    final product = _recommendedProducts[index];
                    return _RecommendedProductCard(
                      product: product,
                      onAdd: () {
                        cart.addItem({
                          'name': product['name'],
                          'price': '₹${product['price']}',
                          'unit': product['unit'],
                          'emoji': product['emoji'],
                          'category': product['category'],
                          'color': _hexToInt(product['color'] ?? '#DCFCE7'),
                          '_id': product['_id'],
                          'image': product['image'] ?? '',
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.primaryDark,
                            duration: const Duration(milliseconds: 900),
                            content: Text('${product['name']} added to cart', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 32),
              ),
            ],
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (_, index) {
                  if (index == _messages.length && _isLoading) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16, left: 8),
                        child: CircularProgressIndicator(color: AppTheme.primaryDark, strokeWidth: 3),
                      ),
                    );
                  }
                  final message = _messages[index];
                  return Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        gradient: message.isUser ? AppTheme.greenGradient : null,
                        color: message.isUser ? null : AppTheme.surface,
                        borderRadius: BorderRadius.circular(20).copyWith(
                          bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                          bottomLeft: !message.isUser ? const Radius.circular(4) : const Radius.circular(20),
                        ),
                        boxShadow: message.isUser ? [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : [AppTheme.cardShadow],
                      ),
                      child: Text(message.text, style: TextStyle(color: message.isUser ? Colors.white : AppTheme.textMain, height: 1.4, fontSize: 15, fontWeight: FontWeight.w500)),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _question,
                    onSubmitted: (_) => _ask(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'How are you feeling today?',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      filled: true,
                      fillColor: AppTheme.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isLoading ? null : _ask,
                  child: Container(
                    height: 52, width: 52,
                    decoration: BoxDecoration(
                      gradient: _isLoading ? null : AppTheme.greenGradient,
                      color: _isLoading ? AppTheme.surfaceMuted : null,
                      shape: BoxShape.circle,
                      boxShadow: _isLoading ? [] : [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: _isLoading 
                      ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryDark)))
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  int _hexToInt(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage(this.text, this.isUser);
}

class _RecommendedProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAdd;
  
  const _RecommendedProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: product['image'] != null && product['image'].toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          product['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Color(_hexToInt(product['color'] ?? '#DCFCE7')).withOpacity(0.15),
                            child: Center(child: Text(product['emoji'] ?? '🍎', style: const TextStyle(fontSize: 44))),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Color(_hexToInt(product['color'] ?? '#DCFCE7')).withOpacity(0.15),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Center(child: Text(product['emoji'] ?? '🍎', style: const TextStyle(fontSize: 44))),
                      ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
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
                Text(
                  product['name'] ?? 'Product',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textMain),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${product['price']} / ${product['unit']}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _hexToInt(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }
}
