import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'view_store_screen.dart';

/// Screen to display a list of approved businesses/stores with search functionality.
class StoresScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const StoresScreen({super.key, this.user});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  List<Map<String, dynamic>> _allBusinesses = [];
  List<Map<String, dynamic>> _filteredBusinesses = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchBusinesses();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Handles search input changes with debouncing to limit filtering frequency.
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text;
        _filterBusinesses();
      });
    });
  }

  /// Filters businesses based on the current search query by name or address.
  void _filterBusinesses() {
    if (_searchQuery.isEmpty) {
      _filteredBusinesses = List.from(_allBusinesses);
    } else {
      _filteredBusinesses = _allBusinesses.where((business) {
        final businessName = business['business_name']?.toLowerCase() ?? '';
        final businessAddress = business['business_address']?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return businessName.contains(query) || businessAddress.contains(query);
      }).toList();
    }
  }

  /// Fetches business data from the server.
  Future<void> _fetchBusinesses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_businesses.php");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _allBusinesses = data.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
          _allBusinesses = _allBusinesses.where((b) => (b['status']?.toString().toLowerCase() == 'approved')).toList();
          _filterBusinesses();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load businesses. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to the server: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150,
        backgroundColor: const Color(0xFFFFD500),
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'All Stores',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Search input field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stores...',
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
                            _filterBusinesses();
                          });
                        },
                      )
                    : null,
              ),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBusinesses,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (_filteredBusinesses.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? "No approved stores available at the moment."
                          : "No stores found for \"$_searchQuery\".",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredBusinesses.length,
                    itemBuilder: (context, index) {
                      final business = _filteredBusinesses[index];
                      final logoUrl = business['logo_url'] != null && business['logo_url'].isNotEmpty
                          ? "http://192.168.137.1/liyag_batangan/${business['logo_url']}"
                          : 'assets/default_store.jpg';

                      return _StoreListItem(
                        name: business['business_name'] ?? 'Unnamed Store',
                        imageUrl: logoUrl,
                        address: business['business_address'] ?? 'No address',
                        onViewStore: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreScreen(
                                business: business,
                                user: widget.user ?? {},
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget to display an individual store item.
class _StoreListItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String address;
  final VoidCallback? onViewStore;

  const _StoreListItem({
    required this.name,
    required this.imageUrl,
    this.address = '',
    this.onViewStore,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = imageUrl.startsWith('http');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onViewStore,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Image/Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: isNetwork
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset('assets/default_store.jpg', fit: BoxFit.cover),
                        )
                      : Image.asset(imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              // Store Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // "View Store" Button
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text("View Store", style: TextStyle(fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}