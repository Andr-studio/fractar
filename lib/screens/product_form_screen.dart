import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _imagenUrlController;
  late TextEditingController _publicoObjetivoController;

  String _selectedCategory = 'Kits Didácticos';
  bool _isLoading = false;
  bool _isEditing = false;
  Product? _existingProduct;

  final List<String> _categories = [
    'Kits Didácticos',
    'Capacitaciones',
    'Material Didáctico',
    'Talleres',
    'Co-diseño',
  ];

  final List<String> _publicoOptions = [
    'Niños y niñas',
    'Jóvenes',
    'Adultos',
    'Docentes',
    'Familias',
    'Todos',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _descripcionController = TextEditingController();
    _precioController = TextEditingController();
    _stockController = TextEditingController();
    _imagenUrlController = TextEditingController();
    _publicoObjetivoController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Product && !_isEditing) {
      _existingProduct = args;
      _isEditing = true;
      _nombreController.text = args.nombre;
      _descripcionController.text = args.descripcion;
      _precioController.text = args.precio.toString();
      _stockController.text = args.stock.toString();
      _imagenUrlController.text = args.imagenUrl;
      _publicoObjetivoController.text = args.publicoObjetivo ?? '';
      _selectedCategory = args.categoria;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _imagenUrlController.dispose();
    _publicoObjetivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B4EAA),
        foregroundColor: Colors.white,
        title: Text(_isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Información Básica'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre del producto',
                hint: 'Ej: Kit Fractar Básico',
                icon: Icons.inventory_2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  if (value.length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  if (value.length > 100) {
                    return 'El nombre no puede exceder 100 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Categoría',
                value: _selectedCategory,
                items: _categories,
                icon: Icons.category,
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descripcionController,
                label: 'Descripción',
                hint: 'Describe el producto...',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es requerida';
                  }
                  if (value.length < 10) {
                    return 'La descripción debe tener al menos 10 caracteres';
                  }
                  if (value.length > 1000) {
                    return 'La descripción no puede exceder 1000 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Precio y Stock'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _precioController,
                      label: 'Precio',
                      hint: '0',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El precio es requerido';
                        }
                        final precio = double.tryParse(value);
                        if (precio == null) {
                          return 'Ingrese un número válido';
                        }
                        if (precio < 0) {
                          return 'El precio no puede ser negativo';
                        }
                        if (precio > 99999999) {
                          return 'El precio es demasiado alto';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _stockController,
                      label: 'Stock',
                      hint: '0',
                      icon: Icons.warehouse,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El stock es requerido';
                        }
                        final stock = int.tryParse(value);
                        if (stock == null) {
                          return 'Ingrese un número válido';
                        }
                        if (stock < 0) {
                          return 'No puede ser negativo';
                        }
                        if (stock > 999999) {
                          return 'Stock demasiado alto';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Información Adicional'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _publicoObjetivoController,
                label: 'Público Objetivo',
                hint: 'Ej: Niños y niñas, Docentes',
                icon: Icons.people,
                validator: (value) {
                  if (value != null && value.length > 200) {
                    return 'No puede exceder 200 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _publicoOptions.map((option) {
                  return ActionChip(
                    label: Text(option, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      final current = _publicoObjetivoController.text;
                      if (current.isEmpty) {
                        _publicoObjetivoController.text = option;
                      } else if (!current.contains(option)) {
                        _publicoObjetivoController.text = '$current, $option';
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _imagenUrlController,
                label: 'URL de la imagen',
                hint: 'https://ejemplo.com/imagen.jpg',
                icon: Icons.image,
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final urlPattern = RegExp(
                      r'^https?:\/\/.+',
                      caseSensitive: false,
                    );
                    if (!urlPattern.hasMatch(value)) {
                      return 'Ingrese una URL válida (debe comenzar con http:// o https://)';
                    }
                  }
                  return null;
                },
              ),
              if (_imagenUrlController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildImagePreview(),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4EAA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isEditing ? Icons.save : Icons.add),
                            const SizedBox(width: 8),
                            Text(
                              _isEditing ? 'Guardar Cambios' : 'Crear Producto',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _showDeleteConfirmation,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text(
                          'Eliminar Producto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF6B4EAA),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6B4EAA)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6B4EAA), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
      onChanged: (value) {
        if (controller == _imagenUrlController) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6B4EAA)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6B4EAA), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(item),
                size: 20,
                color: _getCategoryColor(item),
              ),
              const SizedBox(width: 8),
              Text(item),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(
          _imagenUrlController.text,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No se pudo cargar la imagen',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Error: ${error.toString()}',
                    style: TextStyle(color: Colors.red[400], fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
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

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los errores en el formulario'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final product = Product(
        id: _existingProduct?.id,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        categoria: _selectedCategory,
        precio: double.parse(_precioController.text),
        stock: int.parse(_stockController.text),
        imagenUrl: _imagenUrlController.text.trim(),
        publicoObjetivo: _publicoObjetivoController.text.trim(),
        fechaCreacion: _existingProduct?.fechaCreacion,
      );

      if (_isEditing && _existingProduct?.id != null) {
        await _firestoreService.updateProduct(_existingProduct!.id!, product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        await _firestoreService.createProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${_nombreController.text}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteProduct();
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

  Future<void> _deleteProduct() async {
    if (_existingProduct?.id == null) return;

    setState(() => _isLoading = true);

    try {
      await _firestoreService.deleteProduct(_existingProduct!.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
