import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedCountersPage extends StatefulWidget {
  const SavedCountersPage({super.key});

  @override
  State<SavedCountersPage> createState() => _SavedCountersPageState();
}

class _SavedCountersPageState extends State<SavedCountersPage> {
  List<Map<String, dynamic>> savedCounters = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCounters();
  }

  Future<void> _loadSavedCounters() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('saved_counters') ?? [];

    setState(() {
      savedCounters = savedList
          .map((String jsonString) => json.decode(jsonString) as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _deleteCounter(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('saved_counters') ?? [];
    savedList.removeAt(index);
    await prefs.setStringList('saved_counters', savedList);

    setState(() {
      savedCounters.removeAt(index);
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Counter deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/alphalogo.png",
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              "CounterPro",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
      body: savedCounters.isEmpty
          ? const Center(
        child: Text(
          'No saved counters yet',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: savedCounters.length,
        itemBuilder: (context, index) {
          final counter = savedCounters[index];
          final DateTime timestamp = DateTime.parse(counter['timestamp']);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: CounterCard(
              title: counter['label'],
              count: counter['count'],
              timestamp: '${timestamp.hour}:${timestamp.minute}, ${timestamp.day}/${timestamp.month}/${timestamp.year}',
              onDelete: () => _deleteCounter(index),
            ),
          );
        },
      ),
    );
  }
}

class CounterCard extends StatelessWidget {
  final String title;
  final int count;
  final String timestamp;
  final VoidCallback onDelete;

  const CounterCard({
    required this.title,
    required this.count,
    required this.timestamp,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}