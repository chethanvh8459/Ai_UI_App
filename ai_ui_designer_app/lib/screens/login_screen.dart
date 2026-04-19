import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedLevel = "Beginner";
  final List<String> levels = ["Beginner", "Intermediate", "Advanced"];

  String selectedRole = "Student";
  final List<String> roles = ["Student", "Developer", "Senior Developer"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // 🔥 BACKGROUND IMAGE
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/login_bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔥 LIGHT OVERLAY (important)
          Container(
            color: const Color(0xFFF8F6F1).withOpacity(0.8),
          ),

          // 🔥 LOGIN CARD
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 📧 EMAIL
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: const Color(0xFFF3F3F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔒 PASSWORD
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: const Color(0xFFF3F3F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔥 EXPERIENCE LEVEL
                    DropdownButtonFormField<String>(
                      value: selectedLevel,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Experience Level",
                        prefixIcon: const Icon(Icons.bar_chart),
                        filled: true,
                        fillColor: const Color(0xFFF3F3F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: levels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedLevel = value);
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    // 🔥 ROLE
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Role",
                        prefixIcon: const Icon(Icons.work),
                        filled: true,
                        fillColor: const Color(0xFFF3F3F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedRole = value);
                        }
                      },
                    ),

                    const SizedBox(height: 5),

                    // 🔹 FORGOT PASSWORD
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text("Forgot Password?"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔥 SIGN IN BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {

                          String email = emailController.text.trim();
                          String password = passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please fill all fields")),
                            );
                            return;
                          }

                          if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$')
                              .hasMatch(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Enter valid email")),
                            );
                            return;
                          }

                          if (password.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Min 6 characters")),
                            );
                            return;
                          }

                          // 🔥 REAL BACKEND LOGIN
                          try {
                            final response = await http.post(
                              Uri.parse('http://127.0.0.1:5000/api/auth/login'),
                              headers: {"Content-Type": "application/json"},
                              body: jsonEncode({
                                "email": email,
                                "password": password
                              }),
                            );

                            var data = jsonDecode(response.body);

                            if (response.statusCode == 200) {
                              // Login Success!
                              final prefs = await SharedPreferences.getInstance();
                              
                              // Save real data from DB to local device for the session
                              await prefs.setString("userEmail", data['data']['email']);
                              await prefs.setString("userName", data['data']['username']);
                              await prefs.setString("userLevel", selectedLevel);
                              await prefs.setString("userRole", selectedRole);

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Welcome back, ${data['data']['username']}!")),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(),
                                ),
                              );
                            } else {
                              if (!context.mounted) return;
                              // Invalid credentials
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(data['message'] ?? "Login Failed")),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Server error. Is Node.js running?")),
                            );
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C5470),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignupScreen()),
                        );
                      },
                      child: const Text("New user? Sign Up"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}