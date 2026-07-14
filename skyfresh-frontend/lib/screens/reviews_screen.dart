import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';

class _Brand {
  static const Color dark = Color(0xFF0F172A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFF22C55E);
  static const Color muted = Color(0xFF64748B);
  static const Color bg = Color(0xFFF6FAF7);
  static const Color fieldBg = Color(0xFFF0FDF4);
  static const Color fieldBorder = Color(0xFFBBF7D0);

  static const LinearGradient gradient = LinearGradient(
    colors: [primaryDark, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _rating = 0;
  final _reviewCtrl = TextEditingController();
  String _selectedProduct = 'Fresh Mango 🥭';

  final List<String> _products = [
    'Fresh Mango 🥭', 'Orange Juice 🍊', 'Watermelon 🍉',
    'Fresh Apple 🍎', 'Green Juice 🥬', 'Pineapple 🍍',
  ];

  final List<Map<String, dynamic>> _reviews = [
    {'name': 'Rahul',   'product': 'Fresh Mango 🥭',   'rating': 5, 'review': 'Super fresh and sweet! Loved it!',         'time': '2 days ago'},
    {'name': 'Priya',   'product': 'Orange Juice 🍊',  'rating': 4, 'review': 'Very fresh juice, delivered quickly!',      'time': '3 days ago'},
    {'name': 'Karthik', 'product': 'Watermelon 🍉',    'rating': 5, 'review': 'Perfect for summer. Very juicy!',           'time': '5 days ago'},
    {'name': 'Divya',   'product': 'Green Juice 🥬',   'rating': 4, 'review': 'Healthy and tasty. Will order again!',      'time': '1 week ago'},
  ];

  double get _avgRating => _reviews.isEmpty ? 0
      : _reviews.fold<int>(0, (sum, r) => sum + (r['rating'] as int)) / _reviews.length;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_rating == 0 || _reviewCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
        content: const Text('Please add rating and review!')));
      return;
    }
    setState(() {
      _reviews.insert(0, {
        'name': 'You',
        'product': _selectedProduct,
        'rating': _rating,
        'review': _reviewCtrl.text.trim(),
        'time': 'Just now',
      });
      _rating = 0;
      _reviewCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _Brand.primaryDark,
      content: const Text('Review submitted! Thank you 🌿')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Brand.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: _Brand.gradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reviews ⭐',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                          letterSpacing: -0.5, color: Colors.white)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(_avgRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800,
                              letterSpacing: -0.8, color: Colors.white)),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(5, (i) => Icon(
                                i < _avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 16, color: Colors.white,
                              )),
                            ),
                            Text('${_reviews.length} reviews',
                              style: const TextStyle(color: Colors.white70, fontSize: 12,
                                  fontWeight: FontWeight.w500)),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 14, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Write a Review',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                                letterSpacing: -0.2, color: _Brand.dark)),
                          const SizedBox(height: 16),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: _Brand.fieldBg,
                              border: Border.all(color: _Brand.fieldBorder),
                              borderRadius: BorderRadius.circular(14)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedProduct,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _Brand.primaryDark),
                                items: _products.map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                )).toList(),
                                onChanged: (v) => setState(() => _selectedProduct = v!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          const Text('Your Rating',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
                                color: _Brand.muted, letterSpacing: 0.2)),
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
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Write your review here...',
                              hintStyle: const TextStyle(color: _Brand.muted, fontSize: 13),
                              filled: true,
                              fillColor: _Brand.fieldBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: _Brand.fieldBorder)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: _Brand.fieldBorder)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: _Brand.primaryDark, width: 2)),
                            ),
                          ),
                          const SizedBox(height: 18),

                          GestureDetector(
                            onTap: _submitReview,
                            child: Container(
                              width: double.infinity, height: 52,
                              decoration: BoxDecoration(
                                gradient: _Brand.gradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(
                                  color: _Brand.primaryDark.withOpacity(0.35),
                                  blurRadius: 14, offset: const Offset(0, 6))],
                              ),
                              child: const Center(
                                child: Text('Submit Review →',
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 15, fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    const Text('Customer Reviews',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                          letterSpacing: -0.2, color: _Brand.dark)),
                    const SizedBox(height: 12),

                    ..._reviews.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Container(
                                  width: 38, height: 38,
                                  decoration: BoxDecoration(
                                    gradient: _Brand.gradient,
                                    borderRadius: BorderRadius.circular(12)),
                                  child: Center(
                                    child: Text(r['name'][0],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800))),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14, color: _Brand.dark)),
                                    Text(r['product'],
                                      style: const TextStyle(
                                          fontSize: 11.5, color: _Brand.muted)),
                                  ],
                                ),
                              ]),
                              Text(r['time'],
                                style: const TextStyle(
                                    fontSize: 11, color: _Brand.muted)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < (r['rating'] as int) ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 15, color: const Color(0xFFFBBF24),
                            )),
                          ),
                          const SizedBox(height: 6),
                          Text(r['review'],
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF475569), height: 1.4)),
                        ],
                      ),
                    )),
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