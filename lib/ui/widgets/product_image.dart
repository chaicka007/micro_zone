import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

/// Отображает изображение товара из подходящего источника:
/// 1) байты из БД (фото из галереи), 2) сетевой URL, 3) заглушка.
class ProductImage extends StatelessWidget {
  final ProductModel product;
  final double iconSize;

  const ProductImage({
    super.key,
    required this.product,
    this.iconSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = product.imageBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return Image.memory(
        bytes,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    if (product.imageUrl.isNotEmpty) {
      return Image.network(
        product.imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return SizedBox.expand(
            child: ColoredBox(
              color: Colors.grey.shade100,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        },
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.grey.shade200,
        child: Icon(Icons.image_not_supported, size: iconSize),
      ),
    );
  }
}
