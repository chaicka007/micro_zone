import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoadSuccess extends ProductState {
  final List<ProductModel> products;

  const ProductLoadSuccess(this.products);

  @override
  List<Object> get props => [products];
}

class ProductLoadFailure extends ProductState {
  final String message;

  const ProductLoadFailure(this.message);

  @override
  List<Object> get props => [message];
}
