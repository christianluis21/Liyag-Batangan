import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class OrderScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const OrderScreen({super.key, required this.user});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int selectedTab = 0; // 0 = Cart, 1 = Orders
  List<Map<String, dynamic>> cartItems = [];
  bool isCartLoading = true;

  List<Map<String, dynamic>> orders = [];
  bool isOrdersLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    fetchOrders();
  }

  Future<void> fetchCartItems() async {
    setState(() => isCartLoading = true);
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_cart_items.php");
    try {
      final response = await http.post(url, body: {
        'user_id': widget.user['user_id'].toString(),
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          cartItems = data.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
          isCartLoading = false;
        });
      } else {
        setState(() {
          isCartLoading = false;
          // Optionally show an error message
          // ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text('Failed to load cart items: ${response.statusCode}')),
          // );
        });
      }
    } catch (e) {
      setState(() {
        isCartLoading = false;
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Error fetching cart items: $e')),
        // );
      });
    }
  }

  Future<void> fetchOrders() async {
    setState(() => isOrdersLoading = true);
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/get_orders.php");
    try {
      final response = await http.post(url, body: {
        'user_id': widget.user['user_id'].toString(),
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          orders = data.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
          isOrdersLoading = false;
        });
      } else {
        setState(() {
          isOrdersLoading = false;
          // ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text('Failed to load orders: ${response.statusCode}')),
          // );
        });
      }
    } catch (e) {
      setState(() {
        isOrdersLoading = false;
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Error fetching orders: $e')),
        // );
      });
    }
  }

  Future<void> updateQuantity(int cartItemId, int newQty) async {
    if (newQty < 0) return; // Should not happen with the current logic, but a safeguard

    if (newQty == 0) {
      // If new quantity is 0, ask for confirmation to remove
      bool confirmRemove = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Remove Item"),
                content: const Text("Do you want to remove this item from your cart?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Don't remove
                    child: const Text("No"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true), // Yes, remove
                    child: const Text("Yes"),
                  ),
                ],
              );
            },
          ) ??
          false; // Default to false if dialog is dismissed

      if (confirmRemove) {
        await removeCartItem(cartItemId);
      }
    } else {
      // Update quantity on the server
      final url = Uri.parse("http://192.168.137.1/liyag_batangan/update_cart_quantity.php");
      try {
        final response = await http.post(url, body: {
          'cart_item_id': cartItemId.toString(),
          'quantity': newQty.toString(),
        });

        if (response.statusCode == 200) {
          // Success, refresh cart items
          fetchCartItems();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update quantity: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating quantity: $e')),
        );
      }
    }
  }

  Future<void> removeCartItem(int cartItemId) async {
    final url = Uri.parse("http://192.168.137.1/liyag_batangan/remove_cart_item.php");
    try {
      final response = await http.post(url, body: {
        'cart_item_id': cartItemId.toString(),
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart!')),
        );
        fetchCartItems(); // Refresh cart after removal
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing item: $e')),
      );
    }
  }

  Future<void> placeOrder() async {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty. Add items before placing an order.')),
      );
      return;
    }

    final url = Uri.parse("http://192.168.137.1/liyag_batangan/place_order.php");
    final orderItems = cartItems.map((item) => {
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price': item['price'],
        }).toList();

    try {
      final response = await http.post(url, body: {
        'user_id': widget.user['user_id'].toString(),
        'order_items': jsonEncode(orderItems),
        'total_price': totalPrice().toStringAsFixed(2), // Ensure total price is formatted correctly
        'name': widget.user['name'] ?? '',
        'address': widget.user['address'] ?? '',
        'phone_number': widget.user['phone_number'] ?? '',
      });

      if (response.statusCode == 200) {
        Navigator.of(context).pop(); // Close modal
        fetchCartItems(); // Refresh cart to clear it
        fetchOrders(); // Refresh orders to show the new one
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }

  double totalPrice() {
    double total = 0;
    for (var item in cartItems) {
      final price = double.tryParse(item['price'].toString()) ?? 0;
      final qty = int.tryParse(item['quantity'].toString()) ?? 0;
      total += price * qty;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFD500);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: yellow,
        elevation: 0,
        title: const Text(
          "Cart & Orders",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  _tabButton("Cart", 0, yellow),
                  _tabButton("Orders", 1, yellow),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: selectedTab == 0 ? _cartView() : _ordersView(),
          ),
        ],
      ),
      bottomNavigationBar: selectedTab == 0 && cartItems.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Total: ₱${totalPrice().toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD500),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    onPressed: cartItems.isNotEmpty ? () => _showBillingModal() : null,
                    child: const Text("Place Order", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _tabButton(String label, int tab, Color yellow) {
    final isSelected = selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = tab;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? yellow : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
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
  }

  Widget _cartView() {
    if (isCartLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cartItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Column(
          children: [
            Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              "Your cart is empty.",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        final imageUrl = item['image_url'] != null && item['image_url'].toString().isNotEmpty
            ? "http://192.168.137.1/liyag_batangan/${item['image_url']}"
            : 'assets/default_food.jpg';
        final qty = int.tryParse(item['quantity'].toString()) ?? 1;
        final price = double.tryParse(item['price'].toString()) ?? 0;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: imageUrl.startsWith('http')
                    ? Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset('assets/default_food.jpg', width: 100, height: 100, fit: BoxFit.cover))
                    : Image.asset(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text("₱${price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.orange, fontSize: 15)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              final currentQty = int.parse(item['quantity'].toString());
                              if (currentQty > 0) { // Allow reducing to 0
                                updateQuantity(int.parse(item['cart_item_id'].toString()), currentQty - 1);
                              }
                            },
                          ),
                          Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: qty < 99
                                ? () => updateQuantity(int.parse(item['cart_item_id'].toString()), qty + 1)
                                : null,
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
      },
    );
  }

  void _showBillingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Use min to fit content
              children: [
                const Center(
                  child: Text("Billing Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(height: 16),
                Text("Name: ${widget.user['name'] ?? ''}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Address: ${widget.user['address'] ?? ''}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Contact: ${widget.user['phone_number'] ?? ''}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Text("Products:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...cartItems.map((item) {
                  final price = double.tryParse(item['price'].toString()) ?? 0;
                  final qty = int.tryParse(item['quantity'].toString()) ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(item['name'] ?? '', style: const TextStyle(fontSize: 15))),
                        Text("x$qty", style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 8),
                        Text("₱${(price * qty).toStringAsFixed(2)}", style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("₱${totalPrice().toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD500),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: placeOrder,
                    child: const Text("Place Order", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ordersView() {
    if (isOrdersLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (orders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 60, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              "No order items found.",
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final item = orders[index];
        final imageUrl = item['image_url'] != null && item['image_url'].toString().isNotEmpty
            ? "http://192.168.137.1/liyag_batangan/${item['image_url']}"
            : 'assets/default_food.jpg';
        final qty = int.tryParse(item['quantity'].toString()) ?? 1;
        final price = double.tryParse(item['price'].toString()) ?? 0;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pending", // "Pending" label
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red, // Or any color to signify pending
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showCompleteOrderDialog(); // Call the dialog without URL launching
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange, // Button color
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Complete Order",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Removed the Divider widget below this line
              Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    child: imageUrl.startsWith('http')
                        ? Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Image.asset('assets/default_food.jpg', width: 100, height: 100, fit: BoxFit.cover))
                        : Image.asset(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text("₱${price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.orange, fontSize: 15)),
                          const SizedBox(height: 8),
                          Text("Quantity: $qty", style: const TextStyle(fontSize: 15)),
                          Text("Total: ₱${(double.tryParse(item['total_price']?.toString() ?? '0') ?? 0).toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCompleteOrderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pending Order"),
          content: const Text(
              "To complete the order please login your account to Liyag Batangan website to complete the order."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.orange, // Button color
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Visit Website",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}