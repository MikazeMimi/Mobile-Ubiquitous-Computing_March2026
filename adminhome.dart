//=====1. import Packages & Files==================================================================
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'bookinghistory.dart'; // 👈 new file for full history

//=====2. Declare This page is Stateful(mutable widget)============================================
class AdminHomePage extends StatefulWidget {
  final int userId; // 👈 accept userId from login/ColumnPage
  const AdminHomePage({super.key, required this.userId});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

//=====3. Admin Home Page widget (Engine)=======================================================
class _AdminHomePageState extends State<AdminHomePage> {
  int totalBookings = 0;
  int activeUsers = 0;
  int pendingApprovals = 0;
  List<Map<String, dynamic>> recentActivity = [];
  Map<String, dynamic>? adminData; // 👈 store admin info

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadOverview();
    _loadRecentActivity();
  }

  //-----Display admin data for greeting <admin> & lists of users---------------------------
  Future<void> _loadAdminData() async {
    final db = DatabaseHelper.instance;
    final users = await db.getAllUsers();
    final admin = users.firstWhere((u) => u['id'] == widget.userId, orElse: () => {});
    if (!mounted) return;
    setState(() {
      adminData = admin.isNotEmpty ? admin : null;
    });
  }

  //-----Display all users booking that pending for approval--------------------------------
  Future<void> _loadOverview() async {
    final db = DatabaseHelper.instance;
    final bookings = await db.getAllBookings();
    final users = await db.getAllUsers();

    if (!mounted) return;
    setState(() {
      totalBookings = bookings.length;
      activeUsers = users.length;
      pendingApprovals =
          bookings.where((b) => b['status'] == 'Pending').length;
    });
  }

  //-----Display all recent booking (5 latest)--------------------------------------------
  Future<void> _loadRecentActivity() async {
    final db = DatabaseHelper.instance;
    final bookings = await db.getAllBookings();
    final users = await db.getAllUsers();

    final enrichedBookings = bookings.map((b) {
      final user = users.firstWhere((u) => u['id'] == b['userId'], orElse: () => {});
      return {
        ...b,
        "username": user.isNotEmpty ? user['username'] : "Unknown User",
        "studentId": user.isNotEmpty ? user['studentId'] : "N/A",
      };
    }).toList();

    if (!mounted) return;
    setState(() {
      recentActivity = enrichedBookings.take(5).toList();
    });
  }

   //=====4. Admin Home Page widget (Design)=================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Dynamic Greeting
            Text(
              adminData != null
                  ? "Welcome, ${adminData!['username']} [${adminData!['studentId']}] 👋"
                  : "Welcome, Admin 👋",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E5E4E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Dashboard Overview",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Summary Cards
            Row(
              children: [
                _SummaryCard(
                    icon: Icons.calendar_today,
                    color: Colors.blue,
                    count: "$totalBookings",
                    label: "Total Bookings"),
                _SummaryCard(
                    icon: Icons.people,
                    color: Colors.orange,
                    count: "$activeUsers",
                    label: "Active Users"),
                _SummaryCard(
                    icon: Icons.pending_actions,
                    color: Colors.red,
                    count: "$pendingApprovals",
                    label: "Pending Approvals"),
              ],
            ),
            const SizedBox(height: 24),

            // Booking Statistics (placeholder)
            const Text("Booking Statistics",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E5E4E))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "📊 Chart Placeholder",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Bookings vs Visitors (Weekly)",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Activity
            const Text("Recent Activity",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E5E4E))),
            const SizedBox(height: 12),
            Column(
              children: recentActivity.isEmpty
                  ? [const Text("No recent activity")]
                  : recentActivity.map((b) {
                      return _ActivityCard(
                        icon: b['status'] == 'Pending'
                            ? Icons.access_time
                            : b['status'] == 'Cancelled'
                                ? Icons.cancel
                                : Icons.check_circle,
                        color: b['status'] == 'Pending'
                            ? Colors.orange
                            : b['status'] == 'Cancelled'
                                ? Colors.red
                                : Colors.green,
                        text:
                            "${b['username']} [${b['studentId']}] booking ${b['place']} > (${b['status']})",
                        time: b['date'] ?? "",
                      );
                    }).toList(),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingHistoryPage()),
                  );
                },
                child: const Text("View All Bookings"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Summary Card Widget
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String count;
  final String label;

  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(count,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// Activity Card Widget
class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String time;

  const _ActivityCard({
    required this.icon,
    required this.color,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(text),
        trailing: Text(time, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
