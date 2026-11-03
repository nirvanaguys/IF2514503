import 'package:flutter/material.dart';

import '../../auth/services/auth_service.dart';
import '../../cart/screens/cart_screen.dart';
import '../../cart/services/cart_service.dart';
import '../data/marketplace_demo_data.dart';
import '../services/marketplace_service.dart';
import '../services/wishlist_service.dart';
import '../widgets/widgets.dart';
import 'product_detail_screen.dart';

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
  final MarketplaceService _marketplaceService = MarketplaceService();
  final WishlistService _wishlistService = WishlistService();
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();

  List<String> _categories = MarketplaceDemoData.categories;
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedCategory = 'Semua';
  String _currentSort = 'Terpopuler';
  final Set<String> _wishlistedIds = {};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    final user = _authService.currentUser;
    await Future.wait([
      _loadCategories(),
      _loadProducts(),
      _loadWishlist(),
      _cartService.fetchCart(user?.id),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _marketplaceService.fetchCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _marketplaceService.fetchProducts(
        selectedCategory: _selectedCategory,
        searchQuery: _searchController.text,
        sortBy: _currentSort,
      );
      if (mounted) {
        setState(() {
          _products = products;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat produk. Silakan coba lagi.';
        });
      }
    }
  }

  Future<void> _loadWishlist() async {
    final user = _authService.currentUser;
    if (user != null) {
      final ids = await _wishlistService.fetchWishlistIds(user.id);
      if (mounted) {
        setState(() {
          _wishlistedIds
            ..clear()
            ..addAll(ids);
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
    ).then((_) => setState(() {}));
  }

  Future<void> _addToCart(ProductModel product) async {
    final user = _authService.currentUser;
    await _cartService.addToCart(user?.id, product);
    setState(() {});
    _showMessage(
      '${product.name} ditambahkan ke keranjang (Total: ${_cartService.cartCountNotifier.value} item)',
    );
  }

  Future<void> _toggleWishlist(String productId) async {
    final user = _authService.currentUser;
    final isCurrentlyWishlisted = _wishlistedIds.contains(productId);

    setState(() {
      if (isCurrentlyWishlisted) {
        _wishlistedIds.remove(productId);
        _showMessage('Dihapus dari wishlist.');
      } else {
        _wishlistedIds.add(productId);
        _showMessage('Disimpan ke wishlist.');
      }
    });

    if (user != null) {
      if (isCurrentlyWishlisted) {
        await _wishlistService.removeFromWishlist(user.id, productId);
      } else {
        await _wishlistService.addToWishlist(user.id, productId);
      }
    }
  }

  void _openProductDetail(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          initialIsWishlisted: _wishlistedIds.contains(product.id),
          onAddToCart: _addToCart,
          onWishlistChanged: (wishlisted) {
            setState(() {
              if (wishlisted) {
                _wishlistedIds.add(product.id);
              } else {
                _wishlistedIds.remove(product.id);
              }
            });
          },
        ),
      ),
    );
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MarketplaceHeader(
              onNotificationTap: () => _showMessage('Notifikasi belum tersedia.'),
              onProfileTap: widget.onOpenProfile,
              onCartTap: _openCart,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _initData,
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
                              onChanged: (_) => _loadProducts(),
                              onFilterTap: () => _showMessage(
                                'Filter lanjutan tersedia pada tahap berikutnya.',
                              ),
                            ),
                            const SizedBox(height: 12),
                            MarketplaceCategoryChips(
                              categories: _categories,
                              selectedCategory: _selectedCategory,
                              onCategorySelected: (category) {
                                setState(() => _selectedCategory = category);
                                _loadProducts();
                              },
                            ),
                            const SizedBox(height: 12),
                            MarketplaceSortRow(
                              currentSort: _currentSort,
                              productCount: _products.length,
                              onSortTap: () {
                                setState(() {
                                  _currentSort = _currentSort == 'Terpopuler'
                                      ? 'Harga Termurah'
                                      : 'Terpopuler';
                                });
                                _loadProducts();
                                _showMessage('Urutan diubah ke $_currentSort');
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    if (_isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_errorMessage != null)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Color(0xFFC62828)),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadProducts,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else if (_products.isEmpty)
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
                              final product = _products[index];
                              return ProductCard(
                                product: product,
                                isWishlisted:
                                    _wishlistedIds.contains(product.id),
                                onTap: () => _openProductDetail(product),
                                onAddToCart: () => _addToCart(product),
                                onToggleWishlist: () =>
                                    _toggleWishlist(product.id),
                              );
                            },
                            childCount: _products.length,
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
            ),
          ],
        ),
      ),
    );
  }
}
