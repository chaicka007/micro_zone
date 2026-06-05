import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../screens/product_detail_screen.dart';
import 'product_image.dart';

class ProductGridCard extends StatelessWidget {
  final ProductModel product;

  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OpenContainer<void>(
      transitionDuration: const Duration(milliseconds: 450),
      openColor: scheme.surface,
      closedColor: scheme.surfaceContainerLow,
      closedElevation: 2,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      openBuilder: (_, _) => ProductDetailScreen(product: product),
      closedBuilder: (_, openContainer) => _ClosedCard(
        product: product,
        onTap: openContainer,
      ),
    );
  }
}

class _ClosedCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ClosedCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: ProductImage(product: product),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  ProductStatusBadge(status: product.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductStatusBadge extends StatelessWidget {
  final ProductStatus status;

  const ProductStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isFree = status == ProductStatus.free;
    final color = isFree ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: isFree ? Colors.green.shade700 : Colors.red.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
