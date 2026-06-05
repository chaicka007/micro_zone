import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(const ProductInitial()) {
    on<ProductsLoadRequested>(_onProductsLoadRequested);
    on<ProductAddRequested>(_onProductAddRequested);
    on<ProductUpdateRequested>(_onProductUpdateRequested);
    on<ProductDeleteRequested>(_onProductDeleteRequested);
    on<ProductRentRequested>(_onProductRentRequested);
    on<ProductReturnRequested>(_onProductReturnRequested);
    on<ProductStatusUpdateRequested>(_onProductStatusUpdateRequested);
  }

  Future<void> _onProductsLoadRequested(
    ProductsLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final products = await _productRepository.fetchProducts();
      emit(ProductLoadSuccess(products));
    } catch (_) {
      emit(const ProductLoadFailure('Не удалось загрузить товары'));
    }
  }

  Future<void> _onProductAddRequested(
    ProductAddRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productRepository.addProduct(event.product);
      final products = await _productRepository.fetchProducts();
      emit(ProductLoadSuccess(products));
    } catch (_) {
      emit(const ProductLoadFailure('Не удалось добавить товар'));
    }
  }

  Future<void> _onProductUpdateRequested(
    ProductUpdateRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await _productRepository.updateProduct(event.product);
      final products = await _productRepository.fetchProducts();
      emit(ProductLoadSuccess(products));
    } catch (_) {
      emit(const ProductLoadFailure('Не удалось обновить товар'));
    }
  }

  Future<void> _onProductDeleteRequested(
    ProductDeleteRequested event,
    Emitter<ProductState> emit,
  ) async {
    await _productRepository.deleteProduct(event.productId);
    final products = await _productRepository.fetchProducts();
    emit(ProductLoadSuccess(products));
  }

  Future<void> _onProductRentRequested(
    ProductRentRequested event,
    Emitter<ProductState> emit,
  ) async {
    await _productRepository.rentProduct(
      productId: event.productId,
      userEmail: event.userEmail,
    );
    final products = await _productRepository.fetchProducts();
    emit(ProductLoadSuccess(products));
  }

  Future<void> _onProductReturnRequested(
    ProductReturnRequested event,
    Emitter<ProductState> emit,
  ) async {
    await _productRepository.returnProduct(event.productId);
    final products = await _productRepository.fetchProducts();
    emit(ProductLoadSuccess(products));
  }

  Future<void> _onProductStatusUpdateRequested(
    ProductStatusUpdateRequested event,
    Emitter<ProductState> emit,
  ) async {
    await _productRepository.setStatus(event.productId, event.status);
    final products = await _productRepository.fetchProducts();
    emit(ProductLoadSuccess(products));
  }
}
