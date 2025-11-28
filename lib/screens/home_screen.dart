import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 0;
  String _selectedCategory = 'Todos';

  final List<String> _categories = [
    'Todos',
    'Kits Didácticos',
    'Capacitaciones',
    'Material Didáctico',
    'Talleres',
    'Co-diseño',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B4EAA),
        foregroundColor: Colors.white,
        title: const Text(
          'FRACTAR',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'logout') {
                await _authService.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      child: Icon(Icons.person, size: 20),
                    ),
                    SizedBox(width: 10),
                    Text('Usuario'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/product-form');
              },
              backgroundColor: const Color(0xFF6B4EAA),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'Acerca de',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              selectedColor: const Color(0xFF6B4EAA).withOpacity(0.2),
              checkmarkColor: const Color(0xFF6B4EAA),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildProductsGrid();
      case 1:
        return _buildDashboard();
      case 2:
        return _buildAbout();
      default:
        return _buildProductsGrid();
    }
  }

  Widget _buildProductsGrid() {
    Stream<List<Product>> productsStream = _selectedCategory == 'Todos'
        ? _firestoreService.getProducts()
        : _firestoreService.getProductsByCategory(_selectedCategory);

    return StreamBuilder<List<Product>>(
      stream: productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay productos disponibles',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Agrega tu primer producto',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/product-form'),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Producto'),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return _buildProductCard(products[index]);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/detail', arguments: product);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: _getCategoryColor(product.categoria).withOpacity(0.1),
                child: product.imagenUrl.isNotEmpty
                    ? Image.network(
                        product.imagenUrl,
                        fit: BoxFit.cover,
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
                        errorBuilder: (context, error, stackTrace) {
                          print('Error cargando imagen: $error');
                          print('URL: ${product.imagenUrl}');
                          return _buildPlaceholderImage(product.categoria);
                        },
                      )
                    : _buildPlaceholderImage(product.categoria),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(
                          product.categoria,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.categoria,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getCategoryColor(product.categoria),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.precio.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 0
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.stock > 0
                                ? 'Stock: ${product.stock}'
                                : 'Agotado',
                            style: TextStyle(
                              fontSize: 10,
                              color: product.stock > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(String categoria) {
    return Center(
      child: Icon(
        _getCategoryIcon(categoria),
        size: 50,
        color: _getCategoryColor(categoria).withOpacity(0.5),
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

  Widget _buildDashboard() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _firestoreService.getStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final stats = snapshot.data ?? {};
        final byCategory = stats['byCategory'] as Map<String, int>? ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resumen General',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Productos',
                      '${stats['totalProducts'] ?? 0}',
                      Icons.inventory,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Stock Total',
                      '${stats['totalStock'] ?? 0}',
                      Icons.warehouse,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                'Valor Total Inventario',
                '\$${(stats['totalValue'] ?? 0).toStringAsFixed(0)}',
                Icons.attach_money,
                Colors.green,
                fullWidth: true,
              ),
              const SizedBox(height: 24),
              const Text(
                'Por Categoría',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...byCategory.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCategoryProgressCard(
                    entry.key,
                    entry.value,
                    stats['totalProducts'] ?? 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgressCard(String category, int count, int total) {
    final progress = total > 0 ? count / total : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      color: _getCategoryColor(category),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text('$count productos'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getCategoryColor(category),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4EAA).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 60,
                      color: Color(0xFF6B4EAA),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'FRACTAR',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B4EAA),
                    ),
                  ),
                  const Text(
                    'Imaginar Creando',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'El proyecto "FRACTAR: Imaginar Creando" de la Marca ArtCC es una solución innovadora que integra arte, ciencia y conciencia en el proceso educativo para niños, niñas, jóvenes, adultos y docentes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildAboutCard(
            Icons.lightbulb,
            'Nuestra Propuesta',
            'Estrategias cocreativas que facilitan el intercambio de experiencias y la creación en entornos educativos innovadores.',
            Colors.amber,
          ),
          _buildAboutCard(
            Icons.people,
            'Público Objetivo',
            'Niños, niñas, jóvenes, adultos, docentes y familias interesados en educación transdisciplinar.',
            Colors.blue,
          ),
          _buildAboutCard(
            Icons.shopping_bag,
            'Productos y Servicios',
            'Kits con material concreto, capacitaciones, formaciones, material didáctico y talleres-laboratorios.',
            Colors.green,
          ),
          _buildAboutCard(
            Icons.favorite,
            'Nuestro Impacto',
            'Contribuimos a la descentralización, equidad de género y fortalecimiento de la educación de calidad.',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  void _showSearchDialog() {
    showSearch(
      context: context,
      delegate: ProductSearchDelegate(_firestoreService),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final FirestoreService firestoreService;

  ProductSearchDelegate(this.firestoreService);

  @override
  String get searchFieldLabel => 'Buscar productos...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Busca productos por nombre'),
          ],
        ),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Product>>(
      stream: firestoreService.searchProducts(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No se encontraron productos para "$query"'),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final product = snapshot.data![index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF6B4EAA).withOpacity(0.1),
                child: const Icon(Icons.inventory, color: Color(0xFF6B4EAA)),
              ),
              title: Text(product.nombre),
              subtitle: Text(product.categoria),
              trailing: Text('\$${product.precio.toStringAsFixed(0)}'),
              onTap: () {
                Navigator.pushNamed(context, '/detail', arguments: product);
              },
            );
          },
        );
      },
    );
  }
}
