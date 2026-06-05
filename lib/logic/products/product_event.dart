import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductsLoadRequested extends ProductEvent {
  const ProductsLoadRequested();
}

class ProductAddRequested extends ProductEvent {
  final ProductModel product;

  const ProductAddRequested(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductUpdateRequested extends ProductEvent {
  final ProductModel product;

  const ProductUpdateRequested(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductDeleteRequested extends ProductEvent {
  final String productId;

  const ProductDeleteRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ProductRentRequested extends ProductEvent {
  final String productId;
  final String userEmail;

  const ProductRentRequested({required this.productId, required this.userEmail});

  @override
  List<Object?> get props => [productId, userEmail];
}

class ProductReturnRequested extends ProductEvent {
  final String productId;

  const ProductReturnRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ProductStatusUpdateRequested extends ProductEvent {
  final String productId;
  final ProductStatus status;

  const ProductStatusUpdateRequested({
    required this.productId,
    required this.status,
  });

  @override
  List<Object?> get props => [productId, status];
}
