import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/models/product_model.dart';
import '../../data/models/user_model.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../../logic/products/product_state.dart';

/// Результат обработки отсканированного QR-кода.
enum _ScanOutcome { rented, returned, denied, occupiedByOther }

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.isEmpty ? null : capture.barcodes.first;
    final rawValue = barcode?.rawValue;

    if (rawValue == null || rawValue.trim().isEmpty) return;

    setState(() => _isProcessing = true);
    _controller.stop();

    final productState = context.read<ProductBloc>().state;
    ProductModel? found;

    if (productState is ProductLoadSuccess) {
      try {
        found = productState.products.firstWhere((p) => p.id == rawValue);
      } catch (_) {
        found = null;
      }
    }

    if (!mounted) return;

    if (found == null) {
      _showNotFoundSheet(rawValue);
      return;
    }

    _handleProduct(found);
  }

  /// Решает что сделать с товаром по результатам сканирования:
  /// взять (если свободен) или вернуть (если занят текущим пользователем).
  void _handleProduct(ProductModel product) {
    final authState = context.read<AuthBloc>().state;
    final UserModel? user =
        authState is AuthAuthenticated ? authState.user : null;

    // Доступ есть только у авторизованных пользователей.
    if (user == null) {
      _showResultSheet(product, _ScanOutcome.denied);
      return;
    }

    if (product.status == ProductStatus.free) {
      // Свободен → берём.
      context.read<ProductBloc>().add(ProductRentRequested(
            productId: product.id,
            userEmail: user.email,
          ));
      _showResultSheet(product, _ScanOutcome.rented);
    } else if (product.rentedBy == user.email) {
      // Занят текущим пользователем → возвращаем.
      context.read<ProductBloc>().add(ProductReturnRequested(product.id));
      _showResultSheet(product, _ScanOutcome.returned);
    } else {
      // Занят кем-то другим.
      _showResultSheet(product, _ScanOutcome.occupiedByOther);
    }
  }

  void _showResultSheet(ProductModel product, _ScanOutcome outcome) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ResultSheet(
        product: product,
        outcome: outcome,
        onRetry: () {
          setState(() => _isProcessing = false);
          _controller.start();
        },
      ),
    ).then((_) {
      if (mounted && _isProcessing) {
        setState(() => _isProcessing = false);
        _controller.start();
      }
    });
  }

  void _showNotFoundSheet(String scannedValue) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotFoundSheet(
        scannedValue: scannedValue,
        onRetry: () {
          setState(() => _isProcessing = false);
          _controller.start();
        },
      ),
    ).then((_) {
      if (mounted && _isProcessing) {
        setState(() => _isProcessing = false);
        _controller.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Сканировать QR-код'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flashlight_on_outlined),
            tooltip: 'Фонарик',
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) =>
                _CameraErrorWidget(error: error),
          ),
          const _ScanOverlay(),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          size: Size.infinite,
          painter: _OverlayPainter(),
        ),
        Align(
          alignment: const Alignment(0, 0.6),
          child: Text(
            'Наведите камеру на QR-код товара',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frameSize = size.width * 0.65;
    final left = (size.width - frameSize) / 2;
    final top = (size.height - frameSize) / 2 - 30;
    final frame = Rect.fromLTWH(left, top, frameSize, frameSize);

    // Тёмная маска с вырезом
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(frame, const Radius.circular(12)))
        ..fillType = PathFillType.evenOdd,
      Paint()..color = Colors.black54,
    );

    // Угловые маркеры
    const len = 22.0;
    const r = 10.0;
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Верх-лево
    canvas.drawLine(Offset(left + r, top), Offset(left + r + len, top), p);
    canvas.drawLine(Offset(left, top + r), Offset(left, top + r + len), p);
    // Верх-право
    canvas.drawLine(
        Offset(frame.right - r - len, top), Offset(frame.right - r, top), p);
    canvas.drawLine(Offset(frame.right, top + r),
        Offset(frame.right, top + r + len), p);
    // Низ-лево
    canvas.drawLine(Offset(left, frame.bottom - r - len),
        Offset(left, frame.bottom - r), p);
    canvas.drawLine(Offset(left + r, frame.bottom),
        Offset(left + r + len, frame.bottom), p);
    // Низ-право
    canvas.drawLine(Offset(frame.right, frame.bottom - r - len),
        Offset(frame.right, frame.bottom - r), p);
    canvas.drawLine(Offset(frame.right - r - len, frame.bottom),
        Offset(frame.right - r, frame.bottom), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CameraErrorWidget extends StatelessWidget {
  final MobileScannerException error;

  const _CameraErrorWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    final message = error.errorCode == MobileScannerErrorCode.permissionDenied
        ? 'Доступ к камере запрещён.\nРазрешите доступ в настройках устройства.'
        : 'Не удалось запустить камеру.\n${error.errorDetails?.message ?? ''}';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_outlined,
                size: 72, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultSheet extends StatelessWidget {
  final ProductModel product;
  final _ScanOutcome outcome;
  final VoidCallback onRetry;

  const _ResultSheet({
    required this.product,
    required this.outcome,
    required this.onRetry,
  });

  ({IconData icon, Color color, String title, String subtitle}) get _content =>
      switch (outcome) {
        _ScanOutcome.rented => (
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            title: 'Товар взят',
            subtitle: 'Товар отмечен как занятый. Для возврата отсканируйте QR-код снова.',
          ),
        _ScanOutcome.returned => (
            icon: Icons.keyboard_return_rounded,
            color: Colors.blue,
            title: 'Товар возвращён',
            subtitle: 'Статус изменён на «Свободен».',
          ),
        _ScanOutcome.denied => (
            icon: Icons.lock_outline_rounded,
            color: Colors.orange,
            title: 'Нет доступа',
            subtitle: 'Войдите в аккаунт, чтобы брать товары.',
          ),
        _ScanOutcome.occupiedByOther => (
            icon: Icons.block_rounded,
            color: Colors.red,
            title: 'Товар занят',
            subtitle: 'Этот товар сейчас находится у другого пользователя.',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final c = _content;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(c.icon, size: 64, color: c.color),
          const SizedBox(height: 16),
          Text(
            c.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            c.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}

class _NotFoundSheet extends StatelessWidget {
  final String scannedValue;
  final VoidCallback onRetry;

  const _NotFoundSheet(
      {required this.scannedValue, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _build404Image(),
            const SizedBox(height: 16),
            Text(
              'Товар не найден',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'QR-код не соответствует ни одному товару в системе',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              scannedValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontFamily: 'monospace'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build404Image() {
    return Image.asset(
      'assets/404.jpg',
      height: 130,
      fit: BoxFit.contain,
    );
  }
}
