import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/product_model.dart';
import '../../data/models/user_model.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../widgets/product_card_widget.dart';
import '../widgets/product_image.dart';
import 'add_product_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  void _showQrSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _QrBottomSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(context),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDescriptionSection(context),
                  const SizedBox(height: 24),
                  _buildStatusCard(context),
                  const SizedBox(height: 24),
                  _buildRoleActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQrSheet(context),
        icon: const Icon(Icons.qr_code_rounded),
        label: const Text('QR-код'),
      ),
    );
  }

  Widget _buildRoleActions(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) return const SizedBox.shrink();
        final user = authState.user;

        return switch (user.role) {
          UserRole.admin => _AdminActions(product: product),
          UserRole.user => _UserActions(product: product, currentUser: user),
        };
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: ProductImage(product: product, iconSize: 64),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            product.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(width: 12),
        ProductStatusBadge(status: product.status),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.7,
                color: Colors.grey.shade700,
              ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final isFree = product.status == ProductStatus.free;
    final color = isFree ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFree
                  ? Icons.inventory_2_outlined
                  : Icons.hourglass_empty_rounded,
              color: isFree ? Colors.green.shade700 : Colors.red.shade700,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Статус товара',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  product.status.label,
                  style: TextStyle(
                    color:
                        isFree ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (product.rentedBy != null)
                  Text(
                    'Арендатор: ${product.rentedBy}',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 11),
                  ),
                if (product.rentedAt != null)
                  Text(
                    'Взят: ${_formatDate(product.rentedAt!)}',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Действия для обычного пользователя ──────────────────────────────────────

class _UserActions extends StatelessWidget {
  final ProductModel product;
  final UserModel currentUser;

  const _UserActions({required this.product, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final isFree = product.status == ProductStatus.free;
    final isRentedByMe = product.rentedBy == currentUser.email;

    if (!isFree && !isRentedByMe) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleAction(context),
        icon: Icon(isFree ? Icons.handshake_outlined : Icons.keyboard_return_rounded),
        label: Text(isFree ? 'Взять в аренду' : 'Вернуть'),
        style: isFree
            ? null
            : ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade600),
      ),
    );
  }

  void _handleAction(BuildContext context) {
    if (product.status == ProductStatus.free) {
      context.read<ProductBloc>().add(ProductRentRequested(
            productId: product.id,
            userEmail: currentUser.email,
          ));
    } else {
      context
          .read<ProductBloc>()
          .add(ProductReturnRequested(product.id));
    }
    Navigator.pop(context);
  }
}

// ── Действия для администратора ──────────────────────────────────────────────

class _AdminActions extends StatelessWidget {
  final ProductModel product;

  const _AdminActions({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Управление',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          onPressed: () => _editProduct(context),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Редактировать товар'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _confirmDelete(context),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Удалить товар'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade600,
            side: BorderSide(color: Colors.red.shade300),
          ),
        ),
      ],
    );
  }

  void _editProduct(BuildContext context) {
    // После сохранения экран редактирования закроется сам, а каталог
    // обновится из БД через ProductBloc.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(editProduct: product),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: Text('«${product.name}» будет удалён без возможности восстановления.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<ProductBloc>()
                  .add(ProductDeleteRequested(product.id));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}

// ── QR bottom sheet ──────────────────────────────────────────────────────────

class _QrBottomSheet extends StatelessWidget {
  final ProductModel product;

  const _QrBottomSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10)
              ],
            ),
            child: QrImageView(
              data: product.id,
              version: QrVersions.auto,
              size: 220,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: scheme.primary,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ID: ${product.id}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade400,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ),
        ],
      ),
    );
  }
}
