import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/product_model.dart';
import '../../logic/products/product_bloc.dart';
import '../../logic/products/product_event.dart';
import '../widgets/app_text_field.dart';

class AddProductScreen extends StatefulWidget {
  /// Если передан товар — экран работает в режиме редактирования.
  final ProductModel? editProduct;

  const AddProductScreen({super.key, this.editProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  ProductStatus _status = ProductStatus.free;

  // Картинка из галереи (байты) и/или ссылка из существующего товара.
  Uint8List? _imageBytes;
  String _existingImageUrl = '';

  ProductModel? _savedProduct;

  bool get _isEditMode => widget.editProduct != null;

  @override
  void initState() {
    super.initState();
    final product = widget.editProduct;
    if (product != null) {
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _status = product.status;
      _imageBytes = product.imageBytes;
      _existingImageUrl = product.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // уменьшаем размер, чтобы BLOB не раздувал БД
      imageQuality: 75, // сжатие JPEG
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _existingImageUrl = ''; // выбранное фото имеет приоритет над ссылкой
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_isEditMode) {
      _submitEdit();
    } else {
      _submitAdd();
    }
  }

  void _submitAdd() {
    final id = _generateId();
    final hasPhoto = _imageBytes != null;

    final product = ProductModel(
      id: id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      // Если фото не выбрано — подставляем заглушку из picsum.
      imageUrl: hasPhoto ? '' : 'https://picsum.photos/seed/$id/400/300',
      imageBytes: _imageBytes,
      status: _status,
    );

    context.read<ProductBloc>().add(ProductAddRequested(product));
    setState(() => _savedProduct = product);
  }

  void _submitEdit() {
    final original = widget.editProduct!;

    final updated = ProductModel(
      id: original.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _existingImageUrl,
      imageBytes: _imageBytes,
      status: _status,
      rentedBy: original.rentedBy,
      rentedAt: original.rentedAt,
    );

    context.read<ProductBloc>().add(ProductUpdateRequested(updated));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Товар обновлён')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode
        ? 'Редактировать товар'
        : (_savedProduct == null ? 'Добавить товар' : 'QR-код товара');
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _savedProduct == null ? _buildForm() : _buildQrView(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Название *',
              hint: 'Ноутбук Dell XPS',
              prefixIcon: const Icon(Icons.label_outline),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Введите название';
                if (v.trim().length < 2) return 'Слишком короткое название';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Описание *',
                hintText: 'Краткое описание товара...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description_outlined),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Введите описание';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProductStatus>(
              initialValue: _status,
              decoration: InputDecoration(
                labelText: 'Статус',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant),
                ),
              ),
              items: const [
                DropdownMenuItem(
                    value: ProductStatus.free, child: Text('Свободен')),
                DropdownMenuItem(
                    value: ProductStatus.occupied, child: Text('Занят')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: Icon(
                  _isEditMode ? Icons.save_outlined : Icons.qr_code_rounded),
              label: Text(
                  _isEditMode ? 'Сохранить изменения' : 'Сохранить и получить QR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = _imageBytes != null || _existingImageUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Фото товара',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 180,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: hasImage ? _buildPreview() : _buildEmptyPicker(scheme),
          ),
        ),
        if (hasImage)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Выбрать другое фото'),
            ),
          ),
      ],
    );
  }

  Widget _buildPreview() {
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Image.network(
      _existingImageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const Center(
        child: Icon(Icons.image_not_supported, size: 40),
      ),
    );
  }

  Widget _buildEmptyPicker(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 44, color: scheme.primary),
          const SizedBox(height: 8),
          Text(
            'Выбрать фото из галереи',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView() {
    final product = _savedProduct!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.green, size: 52),
            const SizedBox(height: 10),
            Text(
              'Товар добавлен!',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 12)
                ],
              ),
              child: QrImageView(
                data: product.id,
                version: QrVersions.auto,
                size: 220,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Theme.of(context).colorScheme.primary,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Theme.of(context).colorScheme.primary,
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Вернуться в каталог'),
            ),
          ],
        ),
      ),
    );
  }
}
