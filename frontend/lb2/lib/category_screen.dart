import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'modals.dart'; 
import 'order_screen.dart'; 
import 'product_screen.dart'; 
import 'package:lottie/lottie.dart';
import 'dart:async'; 
import 'dart:math';

/// A screen to display products by category, with search and user interactions.
class CategoryScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final int initialCategory;

  const CategoryScreen({
    super.key,
    required this.user,
    this.initialCategory = 0,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Map<String, dynamic> _user;
  List<Map<String, dynamic>> _allProducts = [];
  bool _isLoading = true;
  int _selectedCategory = 0; // 0 = All, 1 = Food, 2 = Beverage, 3 = Souvenir

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _selectedCategory = widget.initialCategory;
    _fetchProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Debounces search input to prevent excessive rebuilds.
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  /// Fetches product data from the server.
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_products.php");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          // Filter for products with stock and ensure uniqueness.
          final uniqueProducts = <Map<String, dynamic>>{};
          for (var item in data) {
            if (item['stock_quantity'] != null && int.parse(item['stock_quantity'].toString()) > 0) {
              uniqueProducts.add(Map<String, dynamic>.from(item));
            }
          }
          _allProducts = uniqueProducts.toList();
          _isLoading = false;
        });
      } else {
        print('Failed to load products. Status code: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  /// Returns products filtered by selected category and search query.
  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> productsToFilter = [];

    if (_selectedCategory == 0) {
      productsToFilter = List.from(_allProducts)..shuffle(Random());
    } else {
      productsToFilter = _allProducts.where((p) => p['category_id'].toString() == _selectedCategory.toString()).toList();
    }

    if (_searchQuery.isEmpty) {
      return productsToFilter;
    } else {
      return productsToFilter.where((product) {
        final name = product['name']?.toLowerCase() ?? '';
        final description = product['description']?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }
  }

  final Color _yellow = const Color(0xFFFFD500);

  /// Fetches notifications for a given user ID.
  Future<List<Map<String, dynamic>>> _fetchNotifications(String userId) async {
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_notifications.php");
    try {
      final response = await http.post(url, body: {'user_id': userId});
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<Map<String, dynamic>>((notif) => {
              'notification_id': notif['notification_id'].toString(),
              'title': notif['title'],
              'message': notif['message'],
            }).toList();
      } else {
        print('Failed to load notifications. Status code: ${response.statusCode}');
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      throw Exception('Failed to load notifications: $e');
    }
  }

  /// Deletes a notification by its ID.
  Future<void> _deleteNotification(String? id) async {
    if (id == null || id.isEmpty) {
      print("Notification ID is null or empty.");
      return;
    }
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/delete_notification.php");
    try {
      final response = await http.post(url, body: {'notification_id': id});
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print("Delete API response: $json");
      } else {
        print("Delete failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting notification: $e");
    }
  }

  /// Adds a product to the user's cart.
  Future<void> _addToCart(int productId) async {
    final userId = _user['user_id'].toString();
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/add_to_cart_simple.php");
    try {
      final response = await http.post(url, body: {
        'user_id': userId,
        'product_id': productId.toString(),
        'quantity': '1',
      });
      if (response.statusCode == 200) {
        // Show success animation.
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/success1.json', width: 120, height: 120, repeat: false),
                const SizedBox(height: 8),
                const Text(
                  'Added to cart',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
        // Pop dialog after a delay.
        Future.delayed(const Duration(milliseconds: 1500), () {
          Navigator.of(context, rootNavigator: true).pop();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add to cart.')),
        );
      }
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Failed to add to cart.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _user['name'] ?? 'Customer';
    final profileImage = _user['profile_picture'];
    final profileUrl = profileImage != null && profileImage.isNotEmpty
        ? NetworkImage("http://192.168.137.1/liyag_batangan/uploads/$profileImage")
        : const AssetImage('assets/profile1.jpg') as ImageProvider;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: RefreshIndicator(
        onRefresh: _fetchProducts,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: _yellow,
              toolbarHeight: 180,
              automaticallyImplyLeading: false,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Text('HELLO, ', style: TextStyle(fontSize: 20, color: Colors.black)),
                              Expanded(
                                child: Text(
                                  name.toUpperCase(),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                              tooltip: 'Cart & Orders',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderScreen(user: _user),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_active_outlined),
                              onPressed: () {
                                Modals.showNotificationDrawer(
                                  context,
                                  _user['user_id'].toString(),
                                  _fetchNotifications,
                                  _deleteNotification,
                                );
                              },
                            ),
                            // User profile picture for modal.
                            GestureDetector(
                              onTap: () {
                                Modals.showProfileModal(context, _user, (updatedUser) {
                                  setState(() {
                                    _user = updatedUser;
                                  });
                                });
                              },
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                backgroundImage: profileUrl,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search input field.
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 20)),
            SliverToBoxAdapter(child: _buildCategorySelector()),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            // Conditional rendering for loading, empty state, or product grid.
            _isLoading
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : _filteredProducts.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? "No products available in this category."
                                      : "No products found for \"$_searchQuery\" in this category.",
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final product = _filteredProducts[index];
                                  final imageUrl = product['image_url'] != null && product['image_url'].toString().isNotEmpty
                                      ? "http://192.168.137.1/liyag_batangan/${product['image_url']}"
                                      : 'assets/default_food.jpg';

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductScreen(product: product, user: _user),
                                        ),
                                      );
                                    },
                                    child: _foodCard(
                                      product['name'] ?? 'Unnamed',
                                      '₱${product['price']}',
                                      product['description'] ?? '',
                                      imageUrl,
                                      isNetwork: true,
                                      product: product,
                                    ),
                                  );
                                },
                                childCount: _filteredProducts.length,
                              ),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.7,
                              ),
                            ),
                          ),
          ],
        ),
      ),
    );
  }

  /// Builds the category selection row.
  Widget _buildCategorySelector() {
    final categories = ['All', 'Food', 'Beverages', 'Souvenirs'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Row(
          children: List.generate(categories.length, (index) {
            final isSelected = _selectedCategory == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = index;
                    _searchController.clear(); // Clear search when category changes
                    _searchQuery = '';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? _yellow : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Creates a single food/product card widget.
  Widget _foodCard(String name, String price, String description, String imagePath, {bool isNetwork = false, Map<String, dynamic>? product}) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3, // Image takes up more space
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: isNetwork
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/default_food.jpg', // Fallback image on error
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (product != null && product['product_id'] != null) {
                        _addToCart(int.parse(product['product_id'].toString()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product ID not found.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD500),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text("Add to Cart", style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}