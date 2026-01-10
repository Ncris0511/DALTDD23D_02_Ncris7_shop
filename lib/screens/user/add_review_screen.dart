import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/review_service.dart';

class AddReviewScreen extends StatefulWidget {
  final int orderId;
  final int productId;
  final int? variantId;
  final String productName;
  final String productImage;

  const AddReviewScreen({
    super.key,
    required this.orderId,
    required this.productId,
    this.variantId,
    required this.productName,
    required this.productImage,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập nội dung đánh giá!")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Gọi Service và truyền variantId xuống
    final result = await _reviewService.addReview(
      orderId: widget.orderId,
      productId: widget.productId,
      variantId: widget.variantId,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (result['success']) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Thành công"),
            content: const Text("Cảm ơn bạn đã đánh giá sản phẩm!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true); // Đóng và reload
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Thông báo"),
            content: Text(result['message'] ?? "Lỗi không xác định"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đánh giá sản phẩm"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.productImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.productName,
                    style: AppStyles.h3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            Text("Chất lượng sản phẩm", style: AppStyles.body),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _rating = index + 1),
                  icon: Icon(
                    index < _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.primaryYellow,
                    size: 40,
                  ),
                );
              }),
            ),
            Center(
              child: Text(
                _rating == 5
                    ? "Tuyệt vời"
                    : _rating == 4
                    ? "Hài lòng"
                    : _rating == 3
                    ? "Bình thường"
                    : "Tệ",
                style: TextStyle(
                  color: AppColors.primaryYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Hãy chia sẻ cảm nhận...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Gửi đánh giá",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
