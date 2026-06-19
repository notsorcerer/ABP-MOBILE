import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final Widget? addToCartButton;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.addToCartButton,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        height: 140,
                        color: AppTheme.lightGrey,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (_, _, _) => Container(
                        height: 140,
                        color: AppTheme.lightGrey,
                        child: Icon(Icons.image_not_supported, color: AppTheme.grey),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        children: [
                          if (product.isBestSeller)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 4)],
                              ),
                              child: const Text('Best Seller', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                            ),
                          if (product.isBestSeller && product.isNewArrival) const SizedBox(width: 4),
                          if (product.isNewArrival)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 4)],
                              ),
                              child: const Text('Baru', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.accent, height: 1.3),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.priceFormatted,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary),
                          ),
                        ),
                        ?addToCartButton,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
