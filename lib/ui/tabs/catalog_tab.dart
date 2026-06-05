import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../../logic/products/product_state.dart';
import '../widgets/product_card_widget.dart';

class CatalogTab extends StatelessWidget {
  const CatalogTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) => switch (state) {
        ProductInitial() || ProductLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
        ProductLoadSuccess(:final products) => RefreshIndicator(
            onRefresh: () async =>
                context.read<ProductBloc>().add(const ProductsLoadRequested()),
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (_, index) =>
                  ProductGridCard(product: products[index]),
            ),
          ),
        ProductLoadFailure(:final message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<ProductBloc>()
                      .add(const ProductsLoadRequested()),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
