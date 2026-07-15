import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/models/user_profile.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _rating = 0;
  final _reviewCtrl = TextEditingController();
  String? _selectedProduct;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;
  bool _submitting = false;

  double get _avgRating => _reviews.isEmpty
      ? 0
      : _reviews.fold<int>(0, (sum, r) => sum + ((r['rating'] as num?)?.toInt() ?? 0)) / _reviews.length;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getProducts(),
      ApiService.getReviews(),
    ]);
    if (!mounted) return;

    final products = List<Map<String, dynamic>>.from(results[0]);
    final reviews = List<Map<String, dynamic>>.from(results[1]);

    setState(() {
      _products = products;
      _reviews = reviews;
      _selectedProduct = products.isNotEmpty
          ? '${products.first['name']} ${products.first['emoji'] ?? ''}'.trim()
          : null;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0 || _reviewCtrl.text.trim().isEmpty || _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
        content: Text('Please add rating and review!'),
      ));
      return;
    }

    setState(() => _submitting = true);

    Map<String, dynamic>? matchedProduct;
    for (final product in _products) {
      final label = '${product['name']} ${product['emoji'] ?? ''}'.trim();
      if (label == _selectedProduct) {
        matchedProduct = product;
        break;
      }
    }

    final res = await ApiService.submitReview(
      productName: _selectedProduct!,
      rating: _rating,
      comment: _reviewCtrl.text.trim(),
      productId: matchedProduct?['_id']?.toString(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (res['success'] == true) {
      _rating = 0;
      _reviewCtrl.clear();
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryDark,
        content: Text('Review submitted! Thank you'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message']?.toString() ?? 'Could not submit review'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: AppTheme.greenGradient,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Reviews',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Colors.white)),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Text(_avgRating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: Colors.white)),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: List.generate(5, (i) => Icon(
                                        i < _avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      )),
                                    ),
                                    Text('${_reviews.length} reviews',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [AppTheme.cardShadow.copyWith(blurRadius: 14, offset: const Offset(0, 5))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Write a Review',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                                  const SizedBox(height: 16),
                                  if (_products.isEmpty)
                                    const Text('No products available to review yet.', style: TextStyle(color: AppTheme.textMuted))
                                  else
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceAlt,
                                        border: Border.all(color: AppTheme.primaryLight.withOpacity(0.5)),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedProduct,
                                          isExpanded: true,
                                          items: _products.map((p) {
                                            final label = '${p['name']} ${p['emoji'] ?? ''}'.trim();
                                            return DropdownMenuItem(value: label, child: Text(label));
                                          }).toList(),
                                          onChanged: (v) => setState(() => _selectedProduct = v),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 18),
                                  const Text('Your Rating', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: List.generate(5, (i) => GestureDetector(
                                      onTap: () => setState(() => _rating = i + 1),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: Icon(
                                          i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                          size: 34,
                                          color: i < _rating ? const Color(0xFFFBBF24) : Colors.grey[300],
                                        ),
                                      ),
                                    )),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _reviewCtrl,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: 'Write your review here...',
                                      filled: true,
                                      fillColor: AppTheme.surfaceAlt,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: AppTheme.primaryLight.withOpacity(0.5)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: AppTheme.primaryLight.withOpacity(0.5)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(color: AppTheme.primaryDark, width: 2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      onPressed: _submitting || _products.isEmpty ? null : _submitReview,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: _submitting
                                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 26),
                            const Text('Customer Reviews',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                            const SizedBox(height: 12),
                            if (_reviews.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: Text('Be the first to leave a review!', style: TextStyle(color: AppTheme.textMuted))),
                              )
                            else
                              ..._reviews.map((r) {
                                final name = r['userName']?.toString() ?? 'Customer';
                                final rating = (r['rating'] as num?)?.toInt() ?? 0;
                                final createdAt = DateTime.tryParse(r['createdAt']?.toString() ?? '') ?? DateTime.now();
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 38,
                                                height: 38,
                                                decoration: BoxDecoration(
                                                  gradient: AppTheme.greenGradient,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    name.isNotEmpty ? name[0].toUpperCase() : 'C',
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                                  Text(r['productName']?.toString() ?? '', style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Text(formatRelativeTime(createdAt), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: List.generate(5, (i) => Icon(
                                          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                          size: 15,
                                          color: const Color(0xFFFBBF24),
                                        )),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(r['comment']?.toString() ?? '', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4)),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
