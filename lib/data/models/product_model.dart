import 'dart:typed_data';
import 'package:equatable/equatable.dart';

enum ProductStatus { free, occupied }

extension ProductStatusLabel on ProductStatus {
  String get label => switch (this) {
        ProductStatus.free => 'Свободен',
        ProductStatus.occupied => 'Занят',
      };
}

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl; // ссылка на картинку (для seed-товаров)
  final Uint8List? imageBytes; // картинка из галереи, хранится в БД
  final ProductStatus status;
  final String? rentedBy; // email пользователя, взявшего товар
  final DateTime? rentedAt; // когда товар был взят

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl = '',
    this.imageBytes,
    required this.status,
    this.rentedBy,
    this.rentedAt,
  });

  ProductModel copyWith({
    String? name,
    String? description,
    String? imageUrl,
    Uint8List? imageBytes,
    ProductStatus? status,
    String? rentedBy,
    DateTime? rentedAt,
    bool clearRent = false,
  }) =>
      ProductModel(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        imageBytes: imageBytes ?? this.imageBytes,
        status: status ?? this.status,
        rentedBy: clearRent ? null : (rentedBy ?? this.rentedBy),
        rentedAt: clearRent ? null : (rentedAt ?? this.rentedAt),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'imageBytes': imageBytes,
        'status': status.name,
        'rentedBy': rentedBy,
        'rentedAt': rentedAt?.millisecondsSinceEpoch,
      };

  factory ProductModel.fromMap(Map<String, Object?> map) => ProductModel(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        imageUrl: (map['imageUrl'] as String?) ?? '',
        imageBytes: map['imageBytes'] as Uint8List?,
        status: ProductStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => ProductStatus.free,
        ),
        rentedBy: map['rentedBy'] as String?,
        rentedAt: map['rentedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['rentedAt'] as int)
            : null,
      );

  @override
  List<Object?> get props => [id];
}
