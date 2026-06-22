import 'package:flutter/material.dart';
import 'database_helper.dart';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  State<ManageUserPage> createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final db = DatabaseHelper.instance;
    final allUsers = await db.getAllUsers();
    if (!mounted) return;
    setState(() {
      users = allUsers;
    });
  }

  Future<void> _confirmRoleChange(int userId, String newRole) async {
    final db = DatabaseHelper.instance;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Role Change"),
        content: Text("Change this user's role to $newRole?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm")),
        ],
      ),
    );
    if (confirmed == true) {
      await db.updateUserRole(userId, newRole);
      if (!mounted) return;
      _loadUsers();
    }
  }

  Future<void> _confirmStatusChange(int userId, String newStatus) async {
    final db = DatabaseHelper.instance;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Status Change"),
        content: Text("Set this user's status to $newStatus?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm")),
        ],
      ),
    );

    if (confirmed == true) {
      if (newStatus == "Ban") {
        final banOrDelete = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Ban User"),
            content: const Text("Do you want to ban this user or delete them permanently?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, "Cancel"), child: const Text("Cancel")),
              ElevatedButton(onPressed: () => Navigator.pop(context, "Ban"), child: const Text("Just Ban")),
              ElevatedButton(onPressed: () => Navigator.pop(context, "Delete"), child: const Text("Delete User")),
            ],
          ),
        );

        if (banOrDelete == "Ban") {
          await db.updateUserStatus(userId, "Ban");
        } else if (banOrDelete == "Delete") {
          await db.deleteBooking(userId);
          await db.database.then((dbConn) => dbConn.delete("user", where: "id = ?", whereArgs: [userId]));
        }
      } else {
        await db.updateUserStatus(userId, newStatus);
      }
      if (!mounted) return;
      _loadUsers();
    }
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
            const Text("Manage Users",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            Expanded(
              child: users.isEmpty
                  ? const Center(child: Text("No users found"))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top row with theme background + white text
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E5E4E),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(user['username'] ?? "",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white)),
                                    Text(user['studentId'] ?? "",
                                        style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Role + Status dropdowns
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        initialValue: user['role'],
                                        decoration: const InputDecoration(
                                          labelText: "Role",
                                          border: OutlineInputBorder(),
                                        ),
                                        items: ["Admin", "User"]
                                            .map((role) => DropdownMenuItem(
                                                  value: role,
                                                  child: Text(role),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null && value != user['role']) {
                                            _confirmRoleChange(user['id'], value);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        initialValue: user['status'],
                                        decoration: const InputDecoration(
                                          labelText: "Status",
                                          border: OutlineInputBorder(),
                                        ),
                                        items: ["Valid", "Ban"]
                                            .map((status) => DropdownMenuItem(
                                                  value: status,
                                                  child: Text(status),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null && value != user['status']) {
                                            _confirmStatusChange(user['id'], value);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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