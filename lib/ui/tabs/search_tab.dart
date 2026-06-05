import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/qr_scanner_screen.dart';
import '../../data/models/product_model.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_state.dart';
import '../widgets/product_card_widget.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filterProducts(List<ProductModel> all) {
    if (_query.isEmpty) return all;
    final lower = _query.toLowerCase();
    return all
        .where((p) =>
            p.name.toLowerCase().contains(lower) ||
            p.description.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск товаров...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Сканировать QR',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const QrScannerScreen()),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) => switch (state) {
              ProductInitial() || ProductLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
              ProductLoadSuccess(:final products) =>
                _buildResults(_filterProducts(products)),
              ProductLoadFailure(:final message) =>
                Center(child: Text(message)),
              _ => const SizedBox.shrink(),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResults(List<ProductModel> products) {
    if (_query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Введите запрос для поиска',
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Ничего не найдено',
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) => ProductGridCard(product: products[index]),
    );
  }
}
