import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:lottie/lottie.dart';

// Import for Map functionality
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart' as fmap; // Alias to avoid conflict with Material.Map
import 'package:latlong2/latlong.dart'; // For LatLng

class UpdateStoreScreen extends StatefulWidget {
  final Map<String, dynamic> businessInfo;
  final Map<String, dynamic> user;

  const UpdateStoreScreen({super.key, required this.businessInfo, required this.user});

  @override
  State<UpdateStoreScreen> createState() => _UpdateStoreScreenState();
}

class _UpdateStoreScreenState extends State<UpdateStoreScreen> {
  late TextEditingController _businessNameController;
  late TextEditingController _businessAddressController; // Keep this
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController(text: widget.businessInfo['business_name']);
    _businessAddressController = TextEditingController(text: widget.businessInfo['business_address']);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Helper function for showing Lottie dialogs
  void showLottieDialog(String asset, String message) {
    _showLottieDialog(asset: asset, message: message, color: Colors.red); // Default to red for errors
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

  Future<void> _updateStore() async {
    setState(() {
      _isLoading = true;
    });

    final uri = Uri.parse("http://192.168.137.1/liyag_batangan/update_store.php");
    final request = http.MultipartRequest('POST', uri);

    request.fields.addAll({
      'vendor_id': widget.businessInfo['vendor_id'].toString(),
      'business_name': _businessNameController.text,
      'business_address': _businessAddressController.text, // Send the updated address
    });

    if (_selectedImage != null) {
      final fileStream = await http.MultipartFile.fromPath(
        'logo_image',
        _selectedImage!.path,
        filename: path.basename(_selectedImage!.path),
      );
      request.files.add(fileStream);
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _showLottieDialog(
            asset: "assets/animations/success1.json",
            message: "Store details updated successfully!",
            color: Colors.green,
          );
          Navigator.pop(context, true); // Pop with true to indicate success and trigger refresh
        } else {
          _showLottieDialog(
            asset: "assets/animations/error.json",
            message: "Failed to update store: ${data['message'] ?? 'Unknown error'}",
            color: Colors.red,
          );
        }
      } else {
        _showLottieDialog(
          asset: "assets/animations/error.json",
          message: "Server error: ${response.statusCode}",
          color: Colors.red,
        );
      }
    } catch (e) {
      _showLottieDialog(
        asset: "assets/animations/error.json",
        message: "An error occurred: $e",
        color: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ---- Map Related Functions ----
  Future<void> openMapModal() async {
    // Check if location services are enabled
    if (!await Geolocator.isLocationServiceEnabled()) {
      return showLottieDialog('assets/animations/error.json', 'Location services are disabled.');
    }

    // Check and request location permission
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return showLottieDialog('assets/animations/error.json', 'Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return showLottieDialog('assets/animations/error.json', 'Location permission permanently denied. Please enable from settings.');
    }

    // Get current position
    final Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng selectedLatLng = LatLng(pos.latitude, pos.longitude);
    final mapController = fmap.MapController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (ctx, setSB) {
          return SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.75,
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text("Select Your Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      fmap.FlutterMap(
                        mapController: mapController,
                        options: fmap.MapOptions(
                          initialCenter: selectedLatLng,
                          initialZoom: 16,
                          onPositionChanged: (position, hasGesture) {
                            if (hasGesture && position.center != null) {
                              setSB(() {
                                selectedLatLng = position.center!;
                              });
                            }
                          },
                          interactionOptions: const fmap.InteractionOptions(
                            flags: fmap.InteractiveFlag.all & ~fmap.InteractiveFlag.rotate, // Disable rotation only
                          ),
                        ),
                        children: [
                          fmap.TileLayer(
                            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", // ✅ no `{s}` subdomain
                            userAgentPackageName: 'com.liyag.batangan',
                            additionalOptions: const {
                              'User-Agent': 'liyag-batangan-app/1.0 (liyagbatangan@gmail.com)',
                            },
                          ),
                        ],
                      ),
                      const Icon(Icons.location_on, color: Colors.orange, size: 40),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Reverse geocode the selected location
                      final address = await reverseGeocode(selectedLatLng);
                      setState(() {
                        _businessAddressController.text = address; // Update the main screen's address controller
                      });
                      Navigator.pop(ctx); // Close the modal bottom sheet
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Set Location"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD500),
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(50), // Make button full width
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        });
      },
    );
  }

  Future<String> reverseGeocode(LatLng loc) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=${loc.latitude}&lon=${loc.longitude}&addressdetails=1',
    );
    // Add User-Agent header as required by Nominatim
    final resp = await http.get(url, headers: {'User-Agent': 'liyag-batangan-app/1.0 (liyagbatangan@gmail.com)'});

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      // Nominatim's 'display_name' provides a nicely formatted address
      return data['display_name'] ?? '${loc.latitude}, ${loc.longitude}';
    }
    // Return coordinates if reverse geocoding fails
    return '${loc.latitude}, ${loc.longitude}';
  }
  // ---- End Map Related Functions ----

  @override
  Widget build(BuildContext context) {
    final yellow = const Color(0xFFFFD500);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: yellow,
        elevation: 0,
        title: const Text(
          "Update Store",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : (widget.businessInfo['logo_url'] != null &&
                                      widget.businessInfo['logo_url'].isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          "http://192.168.137.1/liyag_batangan/${widget.businessInfo['logo_url']}"),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        alignment: Alignment.center,
                        child: _selectedImage == null &&
                                (widget.businessInfo['logo_url'] == null ||
                                    widget.businessInfo['logo_url'].isEmpty)
                            ? const Icon(Icons.camera_alt, size: 60, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                          labelText: "Business Name",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: _businessAddressController,
                        readOnly: true, // Make it read-only
                        onTap: openMapModal, // Open map modal on tap
                        decoration: const InputDecoration(
                          labelText: "Business Address",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          suffixIcon: Icon(Icons.map, color: Colors.grey), // Add a map icon
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _updateStore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}