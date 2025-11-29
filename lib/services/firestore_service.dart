import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'productos';

  // CREATE
  Future<String> createProduct(Product product) async {
    try {
      DocumentReference docRef = await _db
          .collection(_collection)
          .add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  // READ - Obtener todos los productos
  Stream<List<Product>> getProducts() {
    return _db
        .collection(_collection)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  // READ - Obtener un producto por ID
  Future<Product?> getProductById(String id) async {
    try {
      DocumentSnapshot doc = await _db.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener producto: $e');
    }
  }

  // READ - Obtener productos por categoría
  Stream<List<Product>> getProductsByCategory(String categoria) {
    return _db
        .collection(_collection)
        .where('categoria', isEqualTo: categoria)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  // UPDATE
  Future<void> updateProduct(String id, Product product) async {
    try {
      await _db.collection(_collection).doc(id).update(product.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  // DELETE
  Future<void> deleteProduct(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  // Buscar productos
  Stream<List<Product>> searchProducts(String query) {
    return _db
        .collection(_collection)
        .orderBy('nombre')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  }

  // Obtener estadísticas (actualización en tiempo real)
  Stream<Map<String, dynamic>> getStatistics() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      int totalProducts = snapshot.docs.length;
      int totalStock = 0;
      double totalValue = 0;
      Map<String, int> byCategory = {};

      for (var doc in snapshot.docs) {
        var data = doc.data();
        int stock = data['stock'] ?? 0;
        double precio = (data['precio'] ?? 0).toDouble();
        String categoria = data['categoria'] ?? 'Sin categoría';

        totalStock += stock;
        totalValue += stock * precio;
        byCategory[categoria] = (byCategory[categoria] ?? 0) + 1;
      }

      return {
        'totalProducts': totalProducts,
        'totalStock': totalStock,
        'totalValue': totalValue,
        'byCategory': byCategory,
      };
    });
  }
}
