//=====1. import Packages & Files==================================================================
import 'package:flutter/material.dart';
import 'register.dart';
import 'column.dart';
import 'database_helper.dart';

//=====2. Create State==============================================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

//=====3. Log in widget=================================================================
class _LoginPageState extends State<LoginPage> {
  final TextEditingController idOrUsernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //-----Database connection------------------------------------------------------------------------
  Future<void> _login() async {
    final db = DatabaseHelper.instance;
    final input = idOrUsernameController.text.trim();
    final password = passwordController.text.trim();

    //-----Empty Field validation--------------------------------------------------------------------------
    if (input.isEmpty || password.isEmpty) {
      _showMessage("Please enter username/ID and password");
      return;
    }

    final users = await db.getAllUsers();
    if (!mounted) return;

    //-----username OR studentId & password validation---------------------------------------------------
    final user = users.firstWhere(
      (u) =>
          (u['username'] == input || u['studentId'] == input) &&
          u['password'] == password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      //-----Ban List Validation-------------------------------------------------------------------------
      if (user['status'] == "Ban") {
        _showMessage("Your account has been banned. Please contact admin.");
        return;
      }

      //-----Navigate the user based on their role and ID------------------------------------------------
      final role = user['role'];
      final userId = user['id'];

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ColumnPage(role: role, userId: userId)),
      );
    } else {
      _showMessage("Invalid username/ID or password");
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  //=====4. Log in widget (Design)=================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
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

              // Username OR Student/Staff ID
              TextField(
                controller: idOrUsernameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  hintText: "Username or Student/Staff ID",
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
              const SizedBox(height: 12),

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
                  onPressed: _login,
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      "Register",
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
