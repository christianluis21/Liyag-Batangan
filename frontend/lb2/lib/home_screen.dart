import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'vendor_store_screen.dart';
import 'login_screen.dart';
import 'all_store.dart';
import 'account_management.dart';
import 'create_business.dart';
import 'category_screen.dart';
import 'view_store_screen.dart';
import 'order_screen.dart';
import 'product_screen.dart';
import 'package:lottie/lottie.dart';
import 'dart:math'; // Import for Random class

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, dynamic> user;
  DateTime? _lastBackPressed;

  // For businesses
  List<Map<String, dynamic>> businesses = [];
  bool isBusinessLoading = true;

  List<Map<String, dynamic>> availableProducts = [];
  bool isProductLoading = true;

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredBusinesses = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    user = Map<String, dynamic>.from(widget.user);
    fetchBusinesses();
    fetchAvailableProducts();
    _searchController.addListener(_onSearchChanged); // Listen for changes in the search bar
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterContent();
    });
  }

  void _filterContent() {
    if (_searchQuery.isEmpty) {
      _filteredBusinesses = [];
      _filteredProducts = [];
      return;
    }

    // Filter businesses
    _filteredBusinesses = businesses
        .where((business) =>
            (business['business_name']?.toLowerCase() ?? '')
                .contains(_searchQuery.toLowerCase()) &&
            (business['status']?.toString().toLowerCase() == 'approved'))
        .toList();

    // Filter products
    _filteredProducts = availableProducts
        .where((product) =>
            (product['name']?.toLowerCase() ?? '')
                .contains(_searchQuery.toLowerCase()) ||
            (product['description']?.toLowerCase() ?? '')
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> fetchBusinesses() async {
    setState(() {
      isBusinessLoading = true;
    });
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_businesses.php");
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        businesses = data.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
        isBusinessLoading = false;
        _filterContent(); // Re-filter after fetching
      });
    } else {
      setState(() {
        isBusinessLoading = false;
      });
    }
  }

  Future<void> fetchAvailableProducts() async {
    setState(() => isProductLoading = true);
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_products.php");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        availableProducts = data
            .where((item) => item['stock_quantity'] != null && int.parse(item['stock_quantity'].toString()) > 0)
            .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
            .toList();
        isProductLoading = false;
        _filterContent(); // Re-filter after fetching
      });
    } else {
      setState(() => isProductLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFD500);
    final name = user['name'] ?? 'Customer';
    final profileImage = user['profile_picture'];
    final profileUrl = profileImage != null && profileImage.isNotEmpty
        ? NetworkImage("http://192.168.137.1/liyag_batangan/uploads/$profileImage")
        : const AssetImage('assets/profile1.jpg') as ImageProvider;

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastBackPressed == null || now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
          _lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please press again to exit'), duration: Duration(seconds: 2)),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          backgroundColor: yellow,
          toolbarHeight: 160,
          automaticallyImplyLeading: false, // This line removes the back icon
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
          ),
          flexibleSpace: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
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
                                builder: (_) => OrderScreen(user: user),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_active_outlined),
                          onPressed: () {
                            _showNotificationDrawer(context);
                          },
                        ),
                        GestureDetector(
                          onTap: () => _showProfileModal(context),
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
                TextField(
                  controller: _searchController, // Assign the controller
                  decoration: InputDecoration(
                    hintText: 'Search food, stores, or items...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await fetchBusinesses();
            await fetchAvailableProducts();
            // _filterContent() is called within fetch methods, so no need to call again here
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                if (_searchQuery.isEmpty) ...[
                  _buildCategories(),
                  _sectionHeader('Checkout Stores', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => StoresScreen(user: user)));
                  }, showSeeAll: true),
                  const SizedBox(height: 8),
                  _buildStoreCards(),
                  const SizedBox(height: 30),
                  _sectionHeader('Recommended for You', showSeeAll: false),
                  const SizedBox(height: 8),
                  _buildFoodCards(),
                  const SizedBox(height: 24),
                ] else ...[
                  // Display search results
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    child: Text('Search Results for "$_searchQuery"', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  if (_filteredBusinesses.isNotEmpty) ...[
                    _sectionHeader('Stores', showSeeAll: false),
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredBusinesses.length,
                        itemBuilder: (context, index) {
                          final business = _filteredBusinesses[index];
                          return _storeCard(
                            business['business_name'] ?? '',
                            business['logo_url'] != null && business['logo_url'].isNotEmpty
                                ? "http://192.168.137.1/liyag_batangan/${business['logo_url']}"
                                : 'assets/default_store.jpg',
                            address: business['business_address'] ?? '',
                            onViewStore: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StoreScreen(business: business, user: user),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_filteredProducts.isNotEmpty) ...[
                    _sectionHeader('Products', showSeeAll: false),
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          final imageUrl = product['image_url'] != null && product['image_url'].toString().isNotEmpty
                              ? "http://192.168.137.1/liyag_batangan/${product['image_url']}"
                              : 'assets/default_food.jpg';
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductScreen(product: product, user: user),
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
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (_filteredBusinesses.isEmpty && _filteredProducts.isEmpty && _searchQuery.isNotEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No results found for your search.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileModal(BuildContext context) {
    final profileImage = user['profile_picture'];
    final profileUrl = profileImage != null && profileImage.isNotEmpty
        ? NetworkImage("http://192.168.137.1/liyag_batangan/uploads/$profileImage")
        : const AssetImage('assets/profile1.jpg') as ImageProvider;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 50, backgroundImage: profileUrl),
              const SizedBox(height: 12),
              Text(user['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final updatedUser = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AccountManagementScreen(user: user)),
                  );
                  if (updatedUser != null && mounted) {
                    setState(() {
                      user = Map<String, dynamic>.from(updatedUser);
                    });
                  }
                },
                icon: const Icon(Icons.settings),
                label: const Text("Manage Account"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD500),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 4),
              Text(user['email'], style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              if ((user['user_type']?.toString().toLowerCase() == 'vendor') ||
                  (user['type']?.toString().toLowerCase() == 'vendor'))
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => VendorStoreScreen(user: user)),
                      );
                    },
                    icon: const Icon(Icons.storefront),
                    label: const Text("View My Store"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD500),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              else
                SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Notice"),
                                  content: const Text("To create a Business, visit our Liyag Batangan Website."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.store_mall_directory_rounded),
                            label: const Text("Start Selling"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD500),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Log out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: true,
          initialChildSize: 1.0,
          maxChildSize: 1.0,
          minChildSize: 1.0,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                Future<List<Map<String, dynamic>>> notificationsFuture =
                    _fetchNotifications(user['user_id'].toString());

                void refreshNotifications() {
                  setModalState(() {
                    notificationsFuture = _fetchNotifications(user['user_id'].toString());
                  });
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                        child: Row(
                          children: const [
                            SizedBox(width: 10),
                            Text(
                              "Notifications",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            refreshNotifications();
                          },
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: notificationsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text("No notifications."));
                              }
                              final notifications = snapshot.data!;
                              return ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  final notif = notifications[index];
                                  return Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.notifications, color: Colors.amber),
                                      title: Text(
                                        notif['title'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          notif['message'] ?? '',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: Text(
                                              notif['title'] ?? '',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            content: Text(notif['message'] ?? ''),
                                            actions: [
                                              Center(
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    await _deleteNotification(notif['notification_id'].toString());
                                                    Navigator.pop(context);
                                                    refreshNotifications();
                                                  },
                                                  icon: const Icon(Icons.delete, color: Colors.white),
                                                  label: const Text("Delete", style: TextStyle(color: Colors.white)),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _deleteNotification(String? id) async {
    if (id == null || id.isEmpty) {
      print("Notification ID is null or empty.");
      return;
    }

    final url = Uri.parse("http://192.168.137.1/liyag_batangan/delete_notification.php");
    final response = await http.post(url, body: {'notification_id': id});

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print("Delete API response: $json");
    } else {
      print("Delete failed with status: ${response.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchNotifications(String userId) async {
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_notifications.php");
    final response = await http.post(url, body: {'user_id': userId});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map<Map<String, dynamic>>((notif) => {
            'notification_id': notif['notification_id'].toString(),
            'title': notif['title'],
            'message': notif['message'],
          }).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _categoryCard('ALL', Icons.grid_view, 0),
          _categoryCard('FOOD', Icons.restaurant_menu, 1),
          _categoryCard('BEVERAGES', Icons.local_drink, 2),
          _categoryCard('SOUVENIRS', Icons.card_giftcard, 3),
        ],
      ),
    );
  }

   Widget _categoryCard(String label, IconData icon, int categoryIndex) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryScreen(
              user: user,
              initialCategory: categoryIndex,
            ),
          ),
        );
      },
      child: Container(
        width: 80, // You can adjust this value or make it dynamic if truly needed.
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 30), // You can make this dynamic if needed
            const SizedBox(height: 8),
            Flexible( // Allow text to be flexible and wrap or truncate
              child: Text(
                label,
                textAlign: TextAlign.center, // Center text if it wraps
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 12, // You can adjust this dynamically if text is long
                ),
                maxLines: 1, // Prevent text from taking too much vertical space
                overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _sectionHeader(String title, {VoidCallback? onTap, bool showSeeAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          if (showSeeAll)
            GestureDetector(
              onTap: onTap,
              child: const Text('See All', style: TextStyle(color: Colors.orange, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildStoreCards() {
    return SizedBox(
      height: 300,
      child: isBusinessLoading
          ? const Center(child: CircularProgressIndicator())
          : businesses.where((b) => (b['status']?.toString().toLowerCase() == 'approved')).isEmpty
              ? const Center(child: Text("No stores available."))
              : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: businesses
                      .where((b) => (b['status']?.toString().toLowerCase() == 'approved'))
                      .map((business) => _storeCard(
                            business['business_name'] ?? '',
                            business['logo_url'] != null && business['logo_url'].isNotEmpty
                                ? "http://192.168.137.1/liyag_batangan/${business['logo_url']}"
                                : 'assets/default_store.jpg',
                            address: business['business_address'] ?? '',
                            onViewStore: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StoreScreen(business: business, user: user),
                                ),
                              );
                            },
                          ))
                      .toList(),
                ),
    );
  }

  Widget _storeCard(String name, String imageUrl, {String address = '', VoidCallback? onViewStore}) {
    final isNetwork = imageUrl.startsWith('http');
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isNetwork
                  ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                  : Image.asset(imageUrl, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (address.isNotEmpty)
            Text(address, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewStore,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD500),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text("View Store", style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addToCart(int productId) async {
    final userId = user['user_id'].toString();
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/add_to_cart_simple.php");
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
  }

  Widget _buildFoodCards() {
    // Create a shuffled list of available products
    final random = Random();
    final List<Map<String, dynamic>> shuffledProducts = List.from(availableProducts);
    shuffledProducts.shuffle(random);

    // Take the first 5 products or fewer if not enough are available
    final List<Map<String, dynamic>> productsToShow = shuffledProducts.take(5).toList();

    return SizedBox(
      height: 280,
      child: isProductLoading
          ? const Center(child: CircularProgressIndicator())
          : productsToShow.isEmpty
              ? const Center(child: Text("No products available."))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: productsToShow.length, // Use the limited and shuffled list
                  itemBuilder: (context, index) {
                    final product = productsToShow[index]; // Get product from the limited list
                    final imageUrl = product['image_url'] != null && product['image_url'].toString().isNotEmpty
                        ? "http://192.168.137.1/liyag_batangan/${product['image_url']}"
                        : 'assets/default_food.jpg';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductScreen(product: product, user: user),
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
                ),
    );
  }

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
            flex: 3, // Give more space to the image
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: isNetwork
                  ? Image.network(imagePath, fit: BoxFit.cover, width: double.infinity)
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
                        addToCart(int.parse(product['product_id'].toString()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product ID not found')),
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