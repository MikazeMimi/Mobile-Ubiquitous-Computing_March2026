import 'package:flutter/material.dart';
import 'database_helper.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> filteredBookings = [];
  final TextEditingController searchController = TextEditingController();
  String selectedStatus = "All"; // default filter

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final db = DatabaseHelper.instance;
    final allBookings = await db.getAllBookings();
    final users = await db.getAllUsers();

    // enrich bookings with username + studentId
    final enrichedBookings = allBookings.map((b) {
      final user = users.firstWhere((u) => u['id'] == b['userId'], orElse: () => {});
      return {
        ...b,
        "username": user.isNotEmpty ? user['username'] : "Unknown User",
        "studentId": user.isNotEmpty ? user['studentId'] : "N/A",
      };
    }).toList();

    if (!mounted) return;
    setState(() {
      bookings = enrichedBookings;
      filteredBookings = enrichedBookings;
    });
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      filteredBookings = bookings.where((b) {
        final studentId = b['studentId']?.toString().toLowerCase() ?? "";
        final place = b['place']?.toString().toLowerCase() ?? "";
        final date = b['date']?.toString().toLowerCase() ?? "";
        final time = b['time']?.toString().toLowerCase() ?? "";
        final status = b['status']?.toString() ?? "";

        final matchesSearch = query.isEmpty ||
            studentId.contains(query) ||
            place.contains(query) ||
            date.contains(query) ||
            time.contains(query);

        final matchesStatus =
            selectedStatus == "All" || status == selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        title: const Text(
          "Booking History",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2E5E4E),
      ),
      body: Column(
        children: [
          // 🔍 Search + Status Filter Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search by Student ID, Place, Date, or Time",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    items: ["All", "Pending", "Confirmed", "Cancelled"]
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedStatus = value;
                        _applyFilters();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // 📋 Booking list
          Expanded(
            child: filteredBookings.isEmpty
                ? const Center(child: Text("No bookings found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.event, color: Color(0xFF2E5E4E)),
                          title: Text(
                            "${booking['username']} [${booking['studentId']}] booking ${booking['place']} > (${booking['status']})",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${booking['date']} • ${booking['time']}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}