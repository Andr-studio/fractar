import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final double precio;
  final int stock;
  final String imagenUrl;
  final String? publicoObjetivo;
  final DateTime? fechaCreacion;

  Product({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.precio,
    required this.stock,
    required this.imagenUrl,
    this.publicoObjetivo,
    this.fechaCreacion,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      categoria: data['categoria'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      imagenUrl: data['imagenUrl'] ?? '',
      publicoObjetivo: data['publicoObjetivo'],
      fechaCreacion: data['fechaCreacion'] != null
          ? (data['fechaCreacion'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'precio': precio,
      'stock': stock,
      'imagenUrl': imagenUrl,
      'publicoObjetivo': publicoObjetivo,
      'fechaCreacion': fechaCreacion ?? FieldValue.serverTimestamp(),
    };
  }

  Product copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? categoria,
    double? precio,
    int? stock,
    String? imagenUrl,
    String? publicoObjetivo,
    DateTime? fechaCreacion,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      publicoObjetivo: publicoObjetivo ?? this.publicoObjetivo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
