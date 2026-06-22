//=====1. import Packages & Files==================================================================
import 'package:flutter/material.dart';
import 'database_helper.dart';

//=====2. Root widget==============================================================================
class ProfilePage extends StatefulWidget {
  final int userId; // 👈 accept userId from ColumnPage
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

//=====3. Profile widget (functions)================================================================
class _ProfilePageState extends State<ProfilePage> {
  bool _obscurePassword = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final db = DatabaseHelper.instance;
    final users = await db.getAllUsers();
    final user = users.firstWhere((u) => u['id'] == widget.userId, orElse: () => {});
    if (!mounted) return;
    setState(() {
      userData = user.isNotEmpty ? user : null;
    });
  }

  //------Popup Edit Form for Phone, Course, Semester-------------------------------------------------
  void _showEditProfileDialog() {
    final phoneController = TextEditingController(text: userData?['phone'] ?? "");
    final courseController = TextEditingController(text: userData?['course'] ?? "");
    final semesterController = TextEditingController(text: userData?['semester'] ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number (e.g. 01164046494)"),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(labelText: "Course"),
              ),
              TextField(
                controller: semesterController,
                decoration: const InputDecoration(labelText: "Semester (1–8)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneController.text.trim();
              final course = courseController.text.trim();
              final semester = semesterController.text.trim();

              // ✅ Local Malaysian phone validation
              final phoneRegex = RegExp(r'^0\d{9,10}$');
              if (phone.isNotEmpty && !phoneRegex.hasMatch(phone)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid phone number. Must start with 0 and have 10–11 digits.")),
                );
                return;
              }

              // ✅ Semester validation (must be 1–8 if provided)
              if (semester.isNotEmpty) {
                final semInt = int.tryParse(semester);
                if (semInt == null || semInt < 1 || semInt > 8) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semester must be a number between 1 and 8.")),
                  );
                  return;
                }
              }

              final db = DatabaseHelper.instance;
              await db.updateUserProfile(widget.userId, {
                'phone': phone,
                'course': course,
                'semester': semester,
              });
              Navigator.pop(context);
              _loadUserProfile(); // refresh profile after update
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  //=====4. Profile widget (design)=======================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E5E4E),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  CircleAvatar(
                    radius: 50,
                    backgroundImage: const AssetImage("assets/dp.jpg"),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    userData!['username'] ?? "",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E5E4E),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _InfoCard(icon: Icons.badge, label: "Student/Staff ID", value: userData!['studentId'] ?? ""),
                  const SizedBox(height: 16),

                  _InfoCard(icon: Icons.email, label: "Email", value: userData!['email'] ?? ""),
                  const SizedBox(height: 16),

                  _InfoCard(icon: Icons.phone, label: "Phone", value: userData!['phone'] ?? "Not provided"),
                  const SizedBox(height: 16),

                  _InfoCard(icon: Icons.school, label: "Course", value: userData!['course'] ?? "Not provided"),
                  const SizedBox(height: 16),

                  _InfoCard(icon: Icons.book, label: "Semester", value: userData!['semester'] ?? "Not provided"),
                  const SizedBox(height: 16),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.lock, color: Color(0xFF2E5E4E)),
                      title: const Text("Password"),
                      subtitle: Text(
                        _obscurePassword ? "••••••••" : (userData!['password'] ?? ""),
                        style: const TextStyle(color: Colors.black),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF2E5E4E),
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ✅ Edit Profile Button wired to popup
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5E4E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _showEditProfileDialog,
                      child: const Text("Edit Profile",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

//-----Reusable Info Card------------------------------------------------------------------------------
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E5E4E)),
        title: Text(label),
        subtitle: Text(value, style: const TextStyle(color: Colors.black)),
      ),
    );
  }
}
