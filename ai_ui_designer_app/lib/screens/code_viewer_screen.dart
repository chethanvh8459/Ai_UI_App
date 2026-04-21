import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:stac/stac.dart';
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
    // 🔥 Attempt to parse the JSON string Gemini gave us
    Map<String, dynamic>? uiJson;
    try {
      uiJson = jsonDecode(code);
    } catch (e) {
      debugPrint("Failed to parse JSON: $e");
    }

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
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("JSON copied to clipboard!"), 
                  backgroundColor: Colors.green
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Row(
        children: [
          // 👈 LEFT SIDE: The raw JSON code (for debugging and copying)
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
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
          ),

          // 👉 RIGHT SIDE: The Live Preview Rendered by Mirai!
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: uiJson != null 
                  ? Stac.fromJson(uiJson, context) ?? const Center(child: Text("Stac couldn't render this JSON", style: TextStyle(color: Colors.black)))
                  : const Center(child: Text("Invalid JSON format from AI. Check the left panel.", style: TextStyle(color: Colors.black))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}