import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:lottie/lottie.dart';
import 'update_store.dart'; // Import the new update store screen

class VendorStoreScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const VendorStoreScreen({super.key, required this.user});

  @override
  State<VendorStoreScreen> createState() => _VendorStoreScreenState();
}

class _VendorStoreScreenState extends State<VendorStoreScreen> {
  late Map<String, dynamic> user;
  List<Map<String, dynamic>> products = [];
  Map<String, dynamic>? businessInfo;
  bool isLoading = true;
  String selectedCategoryFilter = 'All'; // New state variable for the filter

  @override
  void initState() {
    super.initState();
    user = Map<String, dynamic>.from(widget.user);
    fetchBusinessInfoAndThenProducts();
    fetchCategories();
  }

  void fetchBusinessInfoAndThenProducts() async {
    await fetchBusinessInfo();
    await fetchProducts();
  }

  List<Map<String, dynamic>> categories = [];

  Future<void> fetchCategories() async {
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_categories.php");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          categories = data.map((item) => Map<String, dynamic>.from(item)).toList();
          // Add an "All" category option
          categories.insert(0, {'category_id': '0', 'name': 'All'});
        });
      } else {
        _showLottieDialog(
          asset: "assets/animations/error.json",
          message: "Failed to load categories: Server error.",
          color: Colors.red,
        );
      }
    } catch (e) {
      _showLottieDialog(
        asset: "assets/animations/error.json",
        message: "Failed to load categories: ${e.toString()}",
        color: Colors.red,
      );
    }
  }

  Future<void> fetchBusinessInfo() async {
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_businesses.php");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final business = data.firstWhere(
          (item) =>
              item['user_id'].toString() == user['user_id'].toString() &&
              item['status'].toString().toLowerCase() == 'approved',
          orElse: () => null,
        );
        if (business != null) {
          setState(() {
            businessInfo = Map<String, dynamic>.from(business);
          });
        }
      } else {
        _showLottieDialog(
          asset: "assets/animations/error.json",
          message: "Failed to load business info: Server error.",
          color: Colors.red,
        );
      }
    } catch (e) {
      _showLottieDialog(
        asset: "assets/animations/error.json",
        message: "Failed to load business info: ${e.toString()}",
        color: Colors.red,
      );
    }
  }

  Future<void> fetchProducts() async {
    if (businessInfo == null || businessInfo!['vendor_id'] == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_vendor_products.php");
    try {
      final response = await http.post(url, body: {
        'vendor_id': businessInfo!['vendor_id'].toString(),
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          products = data.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showLottieDialog(
          asset: "assets/animations/error.json",
          message: "Failed to load products: Server error.",
          color: Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showLottieDialog(
        asset: "assets/animations/error.json",
        message: "Failed to load products: ${e.toString()}",
        color: Colors.red,
      );
    }
  }

  void _showLottieDialog({required String asset, required String message, required Color color}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(asset, height: 150, repeat: false),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    final stockController = TextEditingController();
    int selectedCategory = categories.isNotEmpty && categories.length > 1
        ? int.parse(categories[1]['category_id'].toString()) // Default to first actual category
        : 1; // Fallback default
    File? selectedImage;

    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text("Add Product",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9800),
                        )),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setModalState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: selectedImage != null
                            ? Image.file(selectedImage!, fit: BoxFit.cover)
                            : const Center(child: Text("Tap to select product image")),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Product Name", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Allow decimals for price
                      ],
                      decoration: const InputDecoration(
                        labelText: "Price",
                        prefixText: '₱',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Stock Quantity",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedCategory,
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                      items: categories.where((cat) => cat['category_id'] != '0').map((cat) {
                        return DropdownMenuItem<int>(
                          value: int.parse(cat['category_id'].toString()),
                          child: Text(cat['name']),
                        );
                      }).toList(),
                      decoration: const InputDecoration(labelText: "Category"),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD500),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          if (selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select an image")),
                            );
                            return;
                          }

                          if (nameController.text.isEmpty ||
                              priceController.text.isEmpty ||
                              descController.text.isEmpty ||
                              stockController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please fill all fields")),
                            );
                            return;
                          }

                          final uri = Uri.parse("http://192.168.137.1/liyag_batangan/add_product.php");
                          final request = http.MultipartRequest('POST', uri);

                          request.fields.addAll({
                            'vendor_id': businessInfo?['vendor_id'].toString() ?? '',
                            'name': nameController.text,
                            'price': priceController.text,
                            'description': descController.text,
                            'stock_quantity': stockController.text,
                            'category_id': selectedCategory.toString(),
                          });

                          final fileStream = await http.MultipartFile.fromPath(
                            'product_image',
                            selectedImage!.path,
                            filename: path.basename(selectedImage!.path),
                          );

                          request.files.add(fileStream);

                          Navigator.pop(context); // Dismiss the modal

                          try {
                            final streamedResponse = await request.send();
                            final response = await http.Response.fromStream(streamedResponse);

                            if (response.statusCode == 200) {
                              final responseData = jsonDecode(response.body);
                              if (responseData['status'] == 'success') {
                                _showLottieDialog(
                                  asset: "assets/animations/success1.json",
                                  message: "Product added successfully!",
                                  color: Colors.green,
                                );
                                fetchProducts(); // Refresh the product list
                              } else {
                                _showLottieDialog(
                                  asset: "assets/animations/error.json",
                                  message: "Failed to add product: ${responseData['message']}",
                                  color: Colors.red,
                                );
                              }
                            } else {
                              _showLottieDialog(
                                asset: "assets/animations/error.json",
                                message: "Failed to add product. Server error: ${response.statusCode}",
                                color: Colors.red,
                              );
                            }
                          } catch (e) {
                            _showLottieDialog(
                              asset: "assets/animations/error.json",
                              message: "Failed to add product: ${e.toString()}",
                              color: Colors.red,
                            );
                          }
                        },
                        child: const Text("Add", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStoreManagementModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFFF9800)),
              title: const Text("Update Store Details"),
              onTap: () {
                Navigator.pop(context); // Close the current modal
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateStoreScreen(
                      businessInfo: businessInfo!,
                      user: user,
                    ),
                  ),
                ).then((_) {
                  // Refresh data after returning from update screen
                  fetchBusinessInfoAndThenProducts();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Delete Store"),
              onTap: () {
                Navigator.pop(context); // Close the current modal
                _deleteVendorStore();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteVendorStore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Store"),
        content: const Text("Are you sure you want to delete your store? This cannot be undone."),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Delete"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final url = Uri.parse("http://192.168.137.1/liyag_batangan/delete_store.php");
    try {
      final response = await http.post(url, body: {
        'user_id': user['user_id'].toString(),
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _showLottieDialog(
            asset: "assets/animations/success1.json",
            message: "Store deleted successfully. Your account type has been reverted to a regular user.",
            color: Colors.green,
          );
          // Optionally update the local user object or navigate back
          // to a screen appropriate for a regular user.
          // For example, if you have a way to update the global user state:
          // Provider.of<UserProvider>(context, listen: false).updateUserType('user');
          Navigator.pop(context); // Go back after successful deletion
        } else {
          _showLottieDialog(
            asset: "assets/animations/error.json",
            message: "Failed to delete store. ${data['message'] ?? ''}",
            color: Colors.red,
          );
        }
      } else {
        _showLottieDialog(
          asset: "assets/animations/error.json",
          message: "Failed to connect to server. Please try again.",
          color: Colors.red,
        );
      }
    } catch (e) {
      _showLottieDialog(
        asset: "assets/animations/error.json",
        message: "Error deleting store: ${e.toString()}",
        color: Colors.red,
      );
    }
  }

  Widget _buildProductCard(Map<String, dynamic> product, {bool unavailable = false}) {
    int stock = int.tryParse(product['stock_quantity'].toString()) ?? 0;
    Color stockColor = stock == 0 ? Colors.red : (stock <= 10 ? Colors.orange : Colors.green);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: unavailable ? Colors.grey[200] : null,
      child: ListTile(
        leading: product['image_url'] != null && product['image_url'].isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  "http://192.168.137.1/liyag_batangan/${product['image_url']}",
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, color: Colors.orange, size: 50);
                  },
                ),
              )
            : const Icon(Icons.image_not_supported, color: Colors.orange, size: 50),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['name'] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: unavailable ? Colors.grey[600] : Colors.black,
              ),
            ),
            Text(
              "₱${product['price']}",
              style: TextStyle(
                color: unavailable ? Colors.grey[500] : const Color(0xFFFF9800),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "Stock: $stock",
            style: TextStyle(color: stockColor, fontWeight: FontWeight.w600),
          ),
        ),
        trailing: TextButton.icon(
          onPressed: () {
            _showManageProductModal(product);
          },
          icon: Icon(Icons.settings, color: unavailable ? Colors.grey[600] : Colors.black),
          label: Text("Manage", style: TextStyle(color: unavailable ? Colors.grey[600] : Colors.black)),
        ),
      ),
    );
  }

  void _showManageProductModal(Map<String, dynamic> product) {
    final nameController = TextEditingController(text: product['name']);
    final priceController = TextEditingController(text: product['price'].toString());
    final stockController = TextEditingController(text: product['stock_quantity'].toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Manage Product",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF9800))),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                readOnly: true, // Make product name read-only
                enabled: false,
                decoration: InputDecoration(
                  labelText: "Product Name",
                  border: const OutlineInputBorder(),
                  hintText: product['name'],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: "Price",
                  prefixText: '₱',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                decoration: const InputDecoration(
                  labelText: "Stock Quantity",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Update Product"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: () async {
                  final url = Uri.parse("http://192.168.137.1/liyag_batangan/update_product.php");
                  try {
                    final response = await http.post(url, body: {
                      'product_id': product['product_id'].toString(),
                      'price': priceController.text,
                      'stock_quantity': stockController.text,
                    });

                    Navigator.pop(context); // Dismiss the modal

                    if (response.statusCode == 200) {
                      final responseData = jsonDecode(response.body);
                      if (responseData['status'] == 'success') {
                        _showLottieDialog(
                          asset: "assets/animations/success1.json",
                          message: "Product updated successfully!",
                          color: Colors.green,
                        );
                        fetchProducts(); // Refresh the product list
                      } else {
                        _showLottieDialog(
                          asset: "assets/animations/error.json",
                          message: "Failed to update product: ${responseData['message']}",
                          color: Colors.red,
                        );
                      }
                    } else {
                      _showLottieDialog(
                        asset: "assets/animations/error.json",
                        message: "Failed to update product. Server error: ${response.statusCode}",
                        color: Colors.red,
                      );
                    }
                  } catch (e) {
                    _showLottieDialog(
                      asset: "assets/animations/error.json",
                      message: "Error updating product: ${e.toString()}",
                      color: Colors.red,
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever),
                label: const Text("Delete Product"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Delete Product"),
                      content: const Text("Are you sure you want to delete this product?"),
                      actions: [
                        TextButton(
                          child: const Text("Cancel"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey, // Set foreground color to grey
                          ),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        ElevatedButton(
                          child: const Text("Delete"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white, // Set foreground color to white
                          ),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  final url = Uri.parse("http://192.168.137.1/liyag_batangan/delete_product.php");
                  try {
                    final response = await http.post(url, body: {
                      'product_id': product['product_id'].toString(),
                    });

                    Navigator.pop(context); // Dismiss the modal

                    if (response.statusCode == 200) {
                      final responseData = jsonDecode(response.body);
                      if (responseData['status'] == 'success') {
                        _showLottieDialog(
                          asset: "assets/animations/success1.json",
                          message: "Product deleted successfully!",
                          color: Colors.green,
                        );
                        fetchProducts(); // Refresh the product list
                      } else {
                        _showLottieDialog(
                          asset: "assets/animations/error.json",
                          message: "Failed to delete product: ${responseData['message']}",
                          color: Colors.red,
                        );
                      }
                    } else {
                      _showLottieDialog(
                        asset: "assets/animations/error.json",
                        message: "Failed to delete product. Server error: ${response.statusCode}",
                        color: Colors.red,
                      );
                    }
                  } catch (e) {
                    _showLottieDialog(
                      asset: "assets/animations/error.json",
                      message: "Error deleting product: ${e.toString()}",
                      color: Colors.red,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFD500);

    // Filter products based on selectedCategoryFilter
    List<Map<String, dynamic>> filteredProducts = products.where((product) {
      if (selectedCategoryFilter == 'All') {
        return true; // Show all products
      } else {
        // Find the category_id for the selected category name
        final selectedCat = categories.firstWhere(
          (cat) => cat['name'] == selectedCategoryFilter,
          orElse: () => {'category_id': '-1'}, // Default if not found
        );
        return product['category_id'].toString() == selectedCat['category_id'].toString();
      }
    }).toList();

    List<Map<String, dynamic>> availableProducts = filteredProducts
        .where((p) => int.tryParse(p['stock_quantity'].toString()) != null &&
                      int.parse(p['stock_quantity'].toString()) > 0)
        .toList();

    List<Map<String, dynamic>> unavailableProducts = filteredProducts
        .where((p) => int.tryParse(p['stock_quantity'].toString()) != null &&
                      int.parse(p['stock_quantity'].toString()) <= 0)
        .toList();


    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: yellow,
        elevation: 0,
        title: Text(
          businessInfo != null ? businessInfo!['business_name'] ?? 'My Store' : 'My Store',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            tooltip: "Store Settings",
            onPressed: _showStoreManagementModal,
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          width: 180,
          height: 50,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_business, color: Colors.white),
            label: const Text("Add Product", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: yellow,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: businessInfo == null ? null : _showAddProductDialog, // Disable if businessInfo is null
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 250,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    businessInfo != null &&
                            businessInfo!['logo_url'] != null &&
                            businessInfo!['logo_url'].isNotEmpty
                        ? Image.network(
                            "http://192.168.137.1/liyag_batangan/${businessInfo!['logo_url']}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset("assets/business_placeholder.png", fit: BoxFit.cover);
                            },
                          )
                        : Image.asset("assets/business_placeholder.png", fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              businessInfo != null ? businessInfo!['business_name'] ?? '' : '',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              businessInfo != null ? businessInfo!['business_address'] ?? '' : '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              user['email'] ?? '',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final categoryName = category['name'].toString();
                    final isSelected = selectedCategoryFilter == categoryName;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(categoryName),
                        selected: isSelected,
                        selectedColor: yellow,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategoryFilter = categoryName;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : (availableProducts.isEmpty && unavailableProducts.isEmpty)
                    ? Center(
                        child: Text(
                          selectedCategoryFilter == 'All'
                              ? "No products added yet. Tap + to add."
                              : "No products in the '${selectedCategoryFilter}' category. Tap + to add.",
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchProducts,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (availableProducts.isNotEmpty) ...[
                                const Text("Available Products",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ...availableProducts.map((product) => _buildProductCard(product)).toList(),
                              ],
                              if (unavailableProducts.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text("Unavailable Products",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                                const SizedBox(height: 8),
                                ...unavailableProducts.map((product) => _buildProductCard(product, unavailable: true)).toList(),
                              ],
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}