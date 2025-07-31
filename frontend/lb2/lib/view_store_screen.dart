import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_screen.dart';
import 'package:lottie/lottie.dart';
import 'dart:async'; // Required for Timer for debouncing

class StoreScreen extends StatefulWidget {
  final Map<String, dynamic> business;
  final Map<String, dynamic> user; // Pass user here for cart

  const StoreScreen({super.key, required this.business, required this.user});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  List<Map<String, dynamic>> storeProducts = [];
  bool isLoading = true;
  int selectedCategory = 0; // 0 = All, 1 = Food, 2 = Beverages, 3 = Souvenir

  // --- Search related variables ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce; // For debouncing search input
  // --- End Search related variables ---

  @override
  void initState() {
    super.initState();
    fetchStoreProducts();
    // --- Initialize search listener ---
    _searchController.addListener(_onSearchChanged);
    // --- End initialize search listener ---
  }

  @override
  void dispose() {
    // --- Dispose search controller and debounce timer ---
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    // --- End dispose search controller and debounce timer ---
    super.dispose();
  }

  // --- Debounce mechanism ---
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }
  // --- End Debounce mechanism ---

  Future<void> fetchStoreProducts() async {
    setState(() {
      isLoading = true; // Set loading to true before fetching
    });
    final vendorId = widget.business['vendor_id'];
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_products_by_business.php");
    try {
      final response = await http.post(url, body: {'vendor_id': vendorId.toString()});

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          storeProducts = data
              .where((item) => item['stock_quantity'] != null && int.parse(item['stock_quantity'].toString()) > 0)
              .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
              .toList();
          isLoading = false;
        });
      } else {
        print('Failed to load products. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> productsToFilter = storeProducts;

    // Filter by category first
    if (selectedCategory != 0) {
      productsToFilter = productsToFilter.where((p) => p['category_id'].toString() == selectedCategory.toString()).toList();
    }

    // Then filter by search query
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

  Future<void> addToCart(BuildContext context, int productId) async {
    final userId = widget.user['user_id'].toString();
    if (userId == null || userId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: User not identified. Please log in.')),
    );
    print('Error: user_id is null or empty. Cannot add to cart.');
    return; // Stop execution if user_id is missing
  }
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/add_to_cart_simple.php");
    try {
      final response = await http.post(url, body: {
        'user_id': userId,
        'product_id': productId.toString(),
        'quantity': '1',
      });
      if (response.statusCode == 200) {
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
    final yellow = const Color(0xFFFFD500);
    final business = widget.business;
    final image = (business['logo_url'] != null && business['logo_url'].isNotEmpty)
        ? NetworkImage("http://192.168.137.1/liyag_batangan/${business['logo_url']}")
        : const AssetImage("assets/default_store.jpg") as ImageProvider;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Container(
          decoration: BoxDecoration(
            color: yellow,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          business['business_name'] ?? 'Store',
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController, // Assign the controller
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
                      suffixIcon: _searchController.text.isNotEmpty // Show clear button if text is not empty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = ''; // Clear the search query
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0), // Adjust this value as needed
                  child: _storeBanner(business, image),
                ),
                const SizedBox(height: 10),
                _buildSlidingCategoryFilter(),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? Center(
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
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final imageUrl = product['image_url'] != null && product['image_url'].toString().isNotEmpty
                                ? "http://192.168.137.1/liyag_batangan/${product['image_url']}"
                                : "assets/default_food.jpg";
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductScreen(product: product, user: widget.user),
                                  ),
                                );
                              },
                              child: _productCard(context, product, imageUrl),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _storeBanner(Map<String, dynamic> business, ImageProvider image) {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: image,
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              business['business_name'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              business['business_address'] ?? 'No address available',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              business['business_description'] ?? 'No description available',
              style: const TextStyle(fontSize: 13, color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlidingCategoryFilter() {
    final yellow = const Color(0xFFFFD500);
    final categories = ['All', 'Food', 'Beverages', 'Souvenir'];

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
            final isSelected = selectedCategory == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = index;
                    // Clear search when category changes
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? yellow : Colors.transparent,
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

  Widget _productCard(BuildContext context, Map<String, dynamic> product, String imageUrl) {
    final stockQty = int.tryParse(product['stock_quantity']?.toString() ?? '0') ?? 0;
    final isAvailable = stockQty > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/default_food.jpg', width: 100, height: 100, fit: BoxFit.cover),
                  )
                : Image.asset(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'] ?? 'No description available',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "₱${product['price']}",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text("Stock: ", style: TextStyle(fontSize: 13)),
                              Text(
                                "$stockQty",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isAvailable ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: isAvailable
                            ? () => addToCart(context, int.parse(product['product_id'].toString()))
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD500),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Add to Cart', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}