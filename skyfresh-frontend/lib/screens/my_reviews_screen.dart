import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';
import 'package:skyfresh/api_service.dart';
import 'package:skyfresh/models/user_profile.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loading = true);
    final reviews = await ApiService.getMyReviews();
    if (!mounted) return;
    setState(() {
      _reviews = reviews;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('My Reviews'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _loadReviews,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : _reviews.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(Icons.star_outline_rounded, size: 42, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 16),
                            const Text('No reviews yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            const Text('Share your experience from the Reviews tab', style: TextStyle(color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: _reviews.length,
                    itemBuilder: (_, i) {
                      final review = _reviews[i];
                      final rating = review['rating'] as int? ?? 0;
                      final createdAt = DateTime.tryParse(review['createdAt']?.toString() ?? '') ?? DateTime.now();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    review['productName']?.toString() ?? 'Product',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                  ),
                                ),
                                Text(
                                  formatRelativeTime(createdAt),
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(5, (index) => Icon(
                                index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 18,
                                color: const Color(0xFFFBBF24),
                              )),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review['comment']?.toString() ?? '',
                              style: const TextStyle(color: AppTheme.textMuted, height: 1.4),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
