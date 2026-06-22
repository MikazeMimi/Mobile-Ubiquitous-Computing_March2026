//=====1. import Packages & Files==================================================================
import 'package:flutter/material.dart';
import 'profile.dart';
import 'settings.dart';
import 'login.dart';
import 'adminhome.dart';
import 'managebooking.dart';
import 'manageuser.dart';
import 'publichome.dart';
import 'booking.dart';
import 'history.dart';

//=====2. Root widget==================================================================
class ColumnPage extends StatefulWidget {
  final String role;
  final int userId;

  const ColumnPage({super.key, required this.role, required this.userId});

  @override
  State<ColumnPage> createState() => _ColumnPageState();
}

//=====3. column widget (functions)====================================================
class _ColumnPageState extends State<ColumnPage> {
  int currentIndex = 0;

  //=====4. column widget(design)======================================================
  @override
  Widget build(BuildContext context) {
    // ✅ Pass userId into pages that need it
    final pages = widget.role == "Admin"
        ? [
            AdminHomePage(userId: widget.userId),
            const ManageUserPage(),
            const ManageBookingPage(),
          ]
        : [
            PublicHomePage(userId: widget.userId),
            BookingPage(userId: widget.userId),
            HistoryPage(userId: widget.userId),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CampusPulse",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E5E4E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF2E5E4E)),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2E5E4E)),
              title: const Text("Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userId: widget.userId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF2E5E4E)),
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF2E5E4E)),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: widget.role == "Admin"
            ? const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
                BottomNavigationBarItem(icon: Icon(Icons.collections_bookmark), label: "Bookings"),
              ]
            : const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: "Booking"),
                BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
              ],
      ),
    );
  }
}
