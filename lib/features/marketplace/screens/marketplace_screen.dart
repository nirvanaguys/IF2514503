import 'package:flutter/material.dart';

import '../data/marketplace_demo_data.dart';
import '../widgets/widgets.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({
    super.key,
    this.onNavigateToDiagnosis,
    this.onOpenProfile,
  });

  final VoidCallback? onNavigateToDiagnosis;
  final VoidCallback? onOpenProfile;

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _currentSort = 'Terpopuler';
  int _cartCount = 0;
  final Set<String> _wishlistedIds = {};

  List<MarketProduct> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return MarketplaceDemoData.products.where((product) {
      final matchesCategory = _selectedCategory == 'Semua' ||
          product.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.storeName.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _addToCart(MarketProduct product) {
    setState(() => _cartCount++);
    _showMessage(
      '${product.name} ditambahkan ke keranjang (Total: $_cartCount item)',
    );
  }

  void _toggleWishlist(String productId) {
    setState(() {
      if (_wishlistedIds.contains(productId)) {
        _wishlistedIds.remove(productId);
        _showMessage('Dihapus dari wishlist.');
      } else {
        _wishlistedIds.add(productId);
        _showMessage('Disimpan ke wishlist.');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final products = _filteredProducts;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MarketplaceHeader(
              onNotificationTap: () => _showMessage('Notifikasi belum tersedia.'),
              onProfileTap: widget.onOpenProfile,
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MarketplaceSearchBar(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            onFilterTap: () => _showMessage(
                              'Filter lanjutan tersedia pada tahap berikutnya.',
                            ),
                          ),
                          const SizedBox(height: 12),
                          MarketplaceCategoryChips(
                            categories: MarketplaceDemoData.categories,
                            selectedCategory: _selectedCategory,
                            onCategorySelected: (category) {
                              setState(() => _selectedCategory = category);
                            },
                          ),
                          const SizedBox(height: 12),
                          MarketplaceSortRow(
                            currentSort: _currentSort,
                            productCount: products.length,
                            onSortTap: () {
                              setState(() {
                                _currentSort = _currentSort == 'Terpopuler'
                                    ? 'Harga Termurah'
                                    : 'Terpopuler';
                              });
                              _showMessage('Urutan diubah ke $_currentSort');
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  if (products.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 56,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Produk tidak ditemukan',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Coba kata kunci lain atau pilih kategori "Semua".',
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.52,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              isWishlisted:
                                  _wishlistedIds.contains(product.id),
                              onTap: () => _showMessage(
                                'Detail produk: ${product.name}',
                              ),
                              onAddToCart: () => _addToCart(product),
                              onToggleWishlist: () =>
                                  _toggleWishlist(product.id),
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                      child: ExpertAssistanceCard(
                        onDiagnoseTap: () =>
                            widget.onNavigateToDiagnosis?.call(),
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
}
