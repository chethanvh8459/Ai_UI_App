import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeViewerScreen extends StatelessWidget {
  final String projectName;
  final String code;

  const CodeViewerScreen({
    super.key,
    required this.projectName,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          projectName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // 🔥 COPY TO CLIPBOARD BUTTON
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Code copied to clipboard!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Dark theme for code
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: SelectableText(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.greenAccent,
            ),
          ),
        ),
      ),
    );
  }
}