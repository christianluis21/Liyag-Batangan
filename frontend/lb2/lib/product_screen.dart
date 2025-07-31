import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

class ProductScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final Map<String, dynamic>? user; // Add user as a parameter if needed

  const ProductScreen({super.key, required this.product, this.user});

  Future<void> addToCart(BuildContext context, int productId) async {
    final userId = user?['user_id'].toString();
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green, fontFamily: 'Poppins'),
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

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFD500);
    final imageUrl = product['image_url'] != null && product['image_url'].toString().isNotEmpty
        ? "http://192.168.137.1/liyag_batangan/${product['image_url']}"
        : 'assets/default_food.jpg';
    final stockQty = int.tryParse(product['stock_quantity']?.toString() ?? '0') ?? 0;
    final isAvailable = stockQty > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80), // Reduced app bar height
        child: Container(
          decoration: BoxDecoration(
            color: yellow,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      product['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900, // Make it extra bold
                        fontSize: 22,
                        fontFamily: 'Poppins',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80), // Increased bottom padding for FAB
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), // Slightly more rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), // Match container radius
                    child: imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            height: 250, // Slightly increased image height
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset('assets/default_food.jpg', height: 250, width: double.infinity, fit: BoxFit.cover),
                          )
                        : Image.asset(
                            imageUrl,
                            height: 250, // Slightly increased image height
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20), // Increased padding inside the card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] ?? '',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'), // Larger, bolder title
                        ),
                        const SizedBox(height: 10), // More space
                        Text(
                          product['description'] ?? 'No description available',
                          style: const TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Poppins'), // Slightly larger description font
                        ),
                        const SizedBox(height: 20), // More space
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "₱${product['price']}",
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 28, // Larger price font
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // Adjusted padding
                              decoration: BoxDecoration(
                                color: isAvailable ? Colors.green[100] : Colors.red[100],
                                borderRadius: BorderRadius.circular(25), // More rounded "stock" pill
                              ),
                              child: Text(
                                isAvailable ? "In Stock: $stockQty" : "Out of Stock",
                                style: TextStyle(
                                  color: isAvailable ? Colors.green[700] : Colors.red[700], // Darker green/red for contrast
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15, // Slightly larger font
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 32,
          child: ElevatedButton.icon(
            onPressed: isAvailable && user != null // Only allow add to cart if user is logged in
                ? () => addToCart(context, int.parse(product['product_id'].toString()))
                : null,
            icon: const Icon(Icons.add_shopping_cart, color: Colors.black),
            label: Text(
                user == null ? "Login to Add to Cart" : "Add to Cart", // Dynamic text for guest users
                style: const TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: yellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18), // Increased vertical padding
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Slightly less rounded than pill
              elevation: 5, // Added elevation for the button
              shadowColor: yellow.withOpacity(0.5), // Subtle shadow color
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}