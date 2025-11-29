import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final firestoreService = FirestoreService();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF6B4EAA),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getCategoryColor(product.categoria),
                      _getCategoryColor(product.categoria).withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: product.imagenUrl.isNotEmpty
                    ? Image.network(
                        product.imagenUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(product.categoria),
                      )
                    : _buildPlaceholder(product.categoria),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/product-form',
                    arguments: product,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () =>
                    _showDeleteDialog(context, product, firestoreService),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.nombre,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: product.stock > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Text(
                          product.stock > 0 ? 'Disponible' : 'Agotado',
                          style: TextStyle(
                            color: product.stock > 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        product.categoria,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(product.categoria),
                          size: 18,
                          color: _getCategoryColor(product.categoria),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          product.categoria,
                          style: TextStyle(
                            color: _getCategoryColor(product.categoria),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(
                    'Precio',
                    '\$${product.precio.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Stock disponible',
                    '${product.stock} unidades',
                    Icons.inventory,
                    Colors.blue,
                  ),
                  if (product.publicoObjetivo != null &&
                      product.publicoObjetivo!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      'Público objetivo',
                      product.publicoObjetivo!,
                      Icons.people,
                      Colors.orange,
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.descripcion.isNotEmpty
                          ? product.descripcion
                          : 'Sin descripción disponible.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (product.fechaCreacion != null)
                    Text(
                      'Agregado el ${_formatDate(product.fechaCreacion!)}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/product-form',
                          arguments: product,
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Producto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4EAA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showDeleteDialog(context, product, firestoreService),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Eliminar Producto',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String categoria) {
    return Center(
      child: Icon(
        _getCategoryIcon(categoria),
        size: 100,
        color: Colors.white.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String categoria) {
    switch (categoria) {
      case 'Kits Didácticos':
        return Colors.purple;
      case 'Capacitaciones':
        return Colors.blue;
      case 'Material Didáctico':
        return Colors.orange;
      case 'Talleres':
        return Colors.green;
      case 'Co-diseño':
        return Colors.teal;
      default:
        return const Color(0xFF6B4EAA);
    }
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case 'Kits Didácticos':
        return Icons.backpack;
      case 'Capacitaciones':
        return Icons.school;
      case 'Material Didáctico':
        return Icons.menu_book;
      case 'Talleres':
        return Icons.brush;
      case 'Co-diseño':
        return Icons.design_services;
      default:
        return Icons.category;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(
    BuildContext context,
    Product product,
    FirestoreService service,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${product.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await service.deleteProduct(product.id!);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
