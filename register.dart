//=====1. import Packages & Files==================================================================
import 'package:flutter/material.dart';
import 'login.dart';
import 'database_helper.dart';

//=====2. Root widget==============================================================================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

//=====3. Register widget (Functions)==============================================================
class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  //-----Database Connection------------------------------------------------------------------------
  Future<void> _register() async {
    final username = nameController.text.trim();
    final studentId = studentIdController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    //-----Empty field validation---------------------------------------------------------------------
    if (username.isEmpty || studentId.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage("Please fill in all fields");
      return;
    }

    //-----Student/Staff ID validation (must be 11 digits)--------------------------------------------
    if (studentId.length != 11 || int.tryParse(studentId) == null) {
      _showMessage("Student/Staff ID must be exactly 11 digits");
      return;
    }

    //-----Confirm password match validation----------------------------------------------------------
    if (password != confirm) {
      _showMessage("Passwords do not match");
      return;
    }

    //----Update to Database-----------------------------------------------------------------------------------
    final db = DatabaseHelper.instance;
    try {
      await db.insertUser({
        'username': username,
        'studentId': studentId,
        'email': email,
        'password': password,
        'role': 'User',   // default role
        'status': 'Valid', // default status
        'phone': '',
        'course': '',
        'semester': ''
      });

      if (!mounted) return;
      _showMessage("Registration successful!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage("Error: ${e.toString()}");
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  //=====4. Register widget (design)======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "CampusPulse",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E5E4E),
                ),
              ),
              const SizedBox(height: 40),

              // Username
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  hintText: "Username",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Student/Staff ID
              TextField(
                controller: studentIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.badge),
                  hintText: "Student/Staff ID (11 digits)",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: "Confirm Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Register Button
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
                  onPressed: _register,
                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF2E5E4E),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
