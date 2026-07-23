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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(children: const [
                Icon(Icons.auto_awesome_rounded, color: AppTheme.primary),
                SizedBox(width: 10),
                Text('Smart Nutritionist', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
              ]),
            ),
            
            // Recommended Products Section
            if (_recommendedProducts.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recommended for you', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppTheme.textMain)),
                ),
              ),
              SizedBox(
                height: 180,
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
                            content: Text('${product['name']} added to cart', style: const TextStyle(color: Colors.white)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 24),
            ],
            
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Align(alignment: Alignment.centerLeft, child: Text('Chat', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppTheme.textMain))),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (_, index) {
                  if (index == _messages.length && _isLoading) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: CircularProgressIndicator(color: AppTheme.primary),
                      ),
                    );
                  }
                  final message = _messages[index];
                  return Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(color: message.isUser ? AppTheme.primary : AppTheme.surface, borderRadius: BorderRadius.circular(16)),
                      child: Text(message.text, style: TextStyle(color: message.isUser ? Colors.white : AppTheme.textMain, height: 1.35)),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _question,
                    onSubmitted: (_) => _ask(),
                    decoration: InputDecoration(
                      hintText: 'How are you feeling today?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppTheme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppTheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : _ask,
                    icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, color: Colors.white),
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
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
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
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          product['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Color(_hexToInt(product['color'] ?? '#DCFCE7')).withOpacity(0.1),
                            child: Center(child: Text(product['emoji'] ?? '🍎', style: const TextStyle(fontSize: 40))),
                          ),
                        ),
                      )
                    : Container(
                        color: Color(_hexToInt(product['color'] ?? '#DCFCE7')).withOpacity(0.1),
                        child: Center(child: Text(product['emoji'] ?? '🍎', style: const TextStyle(fontSize: 40))),
                      ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Product',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textMain),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${product['price']} / ${product['unit']}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.primary),
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
