import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../main.dart';
import 'package:ai_ui_designer_app/l10n/app_localizations.dart';
import 'code_viewer_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';
import 'create_project_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  
  List<dynamic> myProjects = [];
  bool isLoadingProjects = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Color primary = const Color(0xFF5A5563);
  final Color accent = const Color(0xFFA3B18A);
  final Color bg = const Color(0xFFF5F3EF);

  Widget _languageIcon() {
    return const Icon(Icons.language, size: 18);
  }

  // 🔥 FETCH PROJECTS FROM NODE.JS
  Future<void> fetchMyProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString("userEmail");

      if (email == null) return;

      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/design/projects/$email'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            myProjects = data['data'];
            isLoadingProjects = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingProjects = false);
      }
      print("Error fetching projects: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Fetch data from database
    fetchMyProjects(); 

    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        leadingWidth: 170,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(t.createProject),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        title: Text(
          t.dashboard,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,

        actions: [
          // 🌙 THEME
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.nightlight_round
                  : Icons.wb_sunny,
            ),
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
          ),

          // 🌐 LANGUAGE 
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                value: MyApp.of(context)?.locale, 
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    MyApp.setLocale(context, newLocale);
                  }
                },
                selectedItemBuilder: (context) {
                  return [_languageIcon(), _languageIcon(), _languageIcon()];
                },
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text("English")),
                  DropdownMenuItem(value: Locale('hi'), child: Text("हिंदी")),
                  DropdownMenuItem(value: Locale('kn'), child: Text("ಕನ್ನಡ")),
                ],
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 HERO 
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    image: const DecorationImage(
                      image: AssetImage("assets/bg.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t.welcome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.headerSubtitle,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 SERVICES
                Text(
                  t.services,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    serviceTab(Icons.web, t.websiteUI),
                    serviceTab(Icons.phone_android, t.mobileUI),
                    serviceTab(Icons.dashboard, t.dashboardUI),
                    serviceTab(Icons.layers, t.components),
                  ],
                ),

                const SizedBox(height: 25),

                // 🔹 TEMPLATES
                Text(
                  t.templates,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return templateCard(
                        "${t.templates} ${index + 1}",
                        "https://picsum.photos/200/300?random=$index",
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // 🔹 PROJECTS
                Text(
                  t.yourProjects,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                // 🔥 DYNAMIC PROJECTS LIST
                isLoadingProjects
                    ? const Center(child: CircularProgressIndicator()) 
                    : myProjects.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.folder_open,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 10),
                                Text(t.noProjects),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: myProjects.length,
                            itemBuilder: (context, index) {
                              var project = myProjects[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFF6A11CB),
                                    child: Icon(Icons.code, color: Colors.white),
                                  ),
                                  title: Text(
                                    project['projectName'] ?? 'Untitled Project',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    project['prompt'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CodeViewerScreen(
                                        projectName: project['projectName'] ?? 'Untitled Project',
                                        code: project['generatedCode'] ?? 'No code found.',
                                      ),
                                    ),
                                  );
                                },
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          );
        },
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget serviceTab(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget templateCard(String title, String imageUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.network(
              imageUrl,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }
}