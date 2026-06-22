import 'package:flutter/material.dart';
import 'database_helper.dart';

class HistoryPage extends StatefulWidget {
  final int userId; // 👈 accept userId
  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> pastBookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final db = DatabaseHelper.instance;
    final allBookings = await db.getAllBookings();

    if (!mounted) return; // ✅ safe before setState
    setState(() {
      // Filter bookings by logged-in user
      pastBookings = allBookings.where((b) => b['userId'] == widget.userId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Booking History",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Expanded(
              child: pastBookings.isEmpty
                  ? const Center(child: Text("No past bookings found"))
                  : ListView.builder(
                      itemCount: pastBookings.length,
                      itemBuilder: (context, index) {
                        final booking = pastBookings[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              booking["place"] ?? "",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date: ${booking["date"] ?? ""}"),
                                Text("Time: ${booking["time"] ?? ""}",
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(booking["status"] ?? ""),
                              backgroundColor: booking["status"] == "Completed"
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              labelStyle: TextStyle(
                                color: booking["status"] == "Completed"
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}