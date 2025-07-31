import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'account_management.dart';
import 'vendor_store_screen.dart';
import 'create_business.dart';

class Modals {
  static void showProfileModal(BuildContext context, Map<String, dynamic> user, Function(Map<String, dynamic>) onUserUpdated) {
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
                  if (updatedUser != null) {
                    onUserUpdated(Map<String, dynamic>.from(updatedUser));
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

  static void showNotificationDrawer(BuildContext context, String userId, Future<List<Map<String, dynamic>>> Function(String) fetchNotifications, Future<void> Function(String?) deleteNotification) {
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
                    fetchNotifications(userId);

                void refreshNotifications() {
                  setModalState(() {
                    notificationsFuture = fetchNotifications(userId);
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
                                                    await deleteNotification(notif['notification_id'].toString());
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
}