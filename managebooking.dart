import 'package:flutter/material.dart';
import 'database_helper.dart';

class ManageBookingPage extends StatefulWidget {
  const ManageBookingPage({super.key});

  @override
  State<ManageBookingPage> createState() => _ManageBookingPageState();
}

class _ManageBookingPageState extends State<ManageBookingPage> {
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final db = DatabaseHelper.instance;
    final allBookings = await db.getAllBookings();

    // join user info
    final allUsers = await db.getAllUsers();
    final enrichedBookings = allBookings.map((b) {
      final user = allUsers.firstWhere((u) => u['id'] == b['userId'], orElse: () => {});
      return {
        ...b,
        "username": user.isNotEmpty ? user['username'] : "Unknown User",
      };
    }).toList();

    if (!mounted) return;
    setState(() {
      // only show pending bookings in ManageBooking
      bookings = enrichedBookings.where((b) => b['status'] == 'Pending').toList();
    });
  }

  Future<void> _confirmApprove(int bookingId) async {
    final db = DatabaseHelper.instance;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Approve Booking"),
        content: const Text("Are you sure you want to approve this booking?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Approve")),
        ],
      ),
    );
    if (confirmed == true) {
      await db.updateBookingStatus(bookingId, "Confirmed");
      _loadBookings(); // ✅ refresh list, approved booking disappears
    }
  }

  Future<void> _confirmCancel(int bookingId) async {
    final db = DatabaseHelper.instance;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text("Are you sure you want to cancel this booking? It will be recorded as history."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes, Cancel")),
        ],
      ),
    );

    if (confirmed == true) {
      await db.updateBookingStatus(bookingId, "Cancelled");
      _loadBookings(); // ✅ refresh list, cancelled booking disappears
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage Bookings",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E5E4E),
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search bookings...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Booking list
            Column(
              children: bookings.map((booking) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: username
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E5E4E),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              booking["username"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Middle row: booking details
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking["date"] ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            Text(booking["time"] ?? "",
                                style: const TextStyle(color: Colors.grey)),
                            Text(booking["place"] ?? "",
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),

                      // Bottom row: approval buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E5E4E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _confirmApprove(booking["id"]),
                                child: const Text("Approve",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _confirmCancel(booking["id"]),
                                child: const Text("Cancel",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}