import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_ui_designer_app/l10n/app_localizations.dart';
import '../utils/auth_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String userLevel = "";
  String userRole = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // 🔥 LOAD USER DATA
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userLevel = prefs.getString("userLevel") ?? "";
      userRole = prefs.getString("userRole") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!; // 🔥 IMPORTANT

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(t.profile),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // 👤 PROFILE IMAGE
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(Icons.person,
                  size: 50, color: Colors.deepPurple),
            ),

            const SizedBox(height: 15),

            // 👤 USERNAME
            Text(
              AuthData.username ?? t.username,
              style: theme.textTheme.titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            // 📧 EMAIL
            Text(
              AuthData.email ?? t.email,
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // 🔥 USER DETAILS CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  infoRow(t.role, userRole.isEmpty ? t.notSet : userRole),
                  const SizedBox(height: 10),
                  infoRow(t.experience, userLevel.isEmpty ? t.notSet : userLevel),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 📊 STATS CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  statItem(t.projects, "0", theme),
                  statItem(t.designs, "0", theme),
                  statItem(t.saved, "0", theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 INFO ROW
  Widget infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // 🔹 STATS
  Widget statItem(String title, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: theme.textTheme.bodySmall!
              .copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}