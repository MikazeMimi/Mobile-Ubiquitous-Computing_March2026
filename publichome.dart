//=====1. import Packages & Files==================================================================
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'booking.dart';

//=====2. Declare Public Home Page State==============================================================================
class PublicHomePage extends StatefulWidget {
  final int userId; // 👈 accept userId from ColumnPage
  const PublicHomePage({super.key, required this.userId});

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

//=====3. public home page widget======================================================
class _PublicHomePageState extends State<PublicHomePage> {
  String selectedCategory = "Study";
  List<Map<String, dynamic>> activeBookings = [];
  Map<String, dynamic>? userData; // 👈 store user info

  //-----dropdown menu lists------------------------------------------------
  final Map<String, List<Map<String, String>>> spaces = {
    "Study": [
      {"title": "Study Room 1", "subtitle": "Library, 1st Floor"},
      {"title": "Study Room 2", "subtitle": "Library, 2nd Floor"},
      {"title": "Study Room 3", "subtitle": "Library, 3rd Floor"},
    ],
    "Sports": [
      {"title": "Badminton Court", "subtitle": "Sports Complex"},
      {"title": "Volleyball Court", "subtitle": "Sports Complex"},
      {"title": "Pickleball Court", "subtitle": "Sports Complex"},
    ],
    "Labs": [
      {"title": "Chemistry Lab", "subtitle": "Science Building"},
      {"title": "Electrical Lab", "subtitle": "Engineering Wing"},
      {"title": "Computer Lab", "subtitle": "Innovation Hub"},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadActiveBookings();
  }

  //-----Database connection--------------------------------------------------------
  Future<void> _loadUserData() async {
    final db = DatabaseHelper.instance;
    final users = await db.getAllUsers();
    final user = users.firstWhere((u) => u['id'] == widget.userId, orElse: () => {});
    if (!mounted) return;
    setState(() {
      userData = user.isNotEmpty ? user : null;
    });
  }

  Future<void> _loadActiveBookings() async {
    final db = DatabaseHelper.instance;
    final allBookings = await db.getAllBookings();

    if (!mounted) return;
    setState(() {
      activeBookings = allBookings
          .where((b) =>
              b['userId'] == widget.userId &&
              (b['status'] == 'Pending' || b['status'] == 'Confirmed'))
          .toList();
    });
  }

  //=====4. public home page widget (design)=====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Dynamic Greeting with username + studentId
            Text(
              userData != null
                  ? "Hi ${userData!['username']} [${userData!['studentId']}] 👋"
                  : "Hi there 👋",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E5E4E),
              ),
            ),
            const SizedBox(height: 20),

            // Active Bookings
            const Text("Active Bookings",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            activeBookings.isEmpty
                ? const Text("No active bookings found")
                : Column(
                    children: activeBookings.map((booking) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(
                            booking["place"] ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Date: ${booking["date"]} • Time: ${booking["time"]}"),
                          trailing: Chip(
                            label: Text(booking["status"] ?? ""),
                            backgroundColor: booking["status"] == "Confirmed"
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            labelStyle: TextStyle(
                              color: booking["status"] == "Confirmed"
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 24),

            // Quick Booking
            const Text("Quick Booking",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Categories with filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CategoryCard(
                  icon: Icons.menu_book,
                  label: "Study",
                  isSelected: selectedCategory == "Study",
                  onTap: () => setState(() => selectedCategory = "Study"),
                ),
                _CategoryCard(
                  icon: Icons.sports_tennis,
                  label: "Sports",
                  isSelected: selectedCategory == "Sports",
                  onTap: () => setState(() => selectedCategory = "Sports"),
                ),
                _CategoryCard(
                  icon: Icons.science,
                  label: "Labs",
                  isSelected: selectedCategory == "Labs",
                  onTap: () => setState(() => selectedCategory = "Labs"),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Spaces filtered by category
            ...spaces[selectedCategory]!.map((space) => _SpaceCard(
                  title: space["title"]!,
                  subtitle: space["subtitle"]!,
                  userId: widget.userId,
                )),
          ],
        ),
      ),
    );
  }
}

//-----Category Card Widget---------------------------------------------------------------------
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                isSelected ? const Color(0xFF2E5E4E) : Colors.grey.shade300,
            child: Icon(icon,
                size: 28,
                color: isSelected ? Colors.white : Colors.grey.shade700),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

//-----Space Card Widget---------------------------------------------------------------------
class _SpaceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int userId;

  const _SpaceCard({
    required this.title,
    required this.subtitle,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E5E4E),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingPage(userId: userId),
              ),
            );
          },
          child: const Text("Book Now!", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}