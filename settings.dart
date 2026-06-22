import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,          // white font
            fontWeight: FontWeight.bold,  // bold for emphasis
          ),
        ),
        backgroundColor: const Color(0xFF2E5E4E)
      ),
      backgroundColor: const Color(0xFFF8F6F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Settings",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E5E4E))),
            const SizedBox(height: 20),

            // Notifications toggle
            Card(
              child: SwitchListTile(
                activeColor: const Color(0xFF2E5E4E),
                title: const Text("Enable Notifications"),
                subtitle: const Text("Receive booking updates and reminders"),
                value: _notificationsEnabled,
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                },
              ),
            ),
            const SizedBox(height: 12),

            // Dark Mode toggle
            Card(
              child: SwitchListTile(
                activeColor: const Color(0xFF2E5E4E),
                title: const Text("Dark Mode"),
                subtitle: const Text("Switch to dark theme"),
                value: _darkModeEnabled,
                onChanged: (val) {
                  setState(() => _darkModeEnabled = val);
                },
              ),
            ),
            const SizedBox(height: 12),

            // Account section
            const Text("Account",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E5E4E))),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF2E5E4E)),
                title: const Text("Edit Profile"),
                onTap: () {
                  // Navigate to profile edit page
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock, color: Color(0xFF2E5E4E)),
                title: const Text("Change Password"),
                onTap: () {
                  // Navigate to change password page
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout"),
                onTap: () {
                  // Handle logout
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
