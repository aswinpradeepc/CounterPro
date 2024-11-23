import 'package:counterplus/saved_counters.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 0;
  int? endValue;
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  // Load counter value from SharedPreferences
  Future<void> _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      count = prefs.getInt('counter') ?? 0;
    });
  }

  // Save counter value to SharedPreferences
  Future<void> _saveCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', count);
  }

  // Save counter with label
  Future<void> _saveCounterWithLabel(String label) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCounters = prefs.getStringList('saved_counters') ?? [];

    final counterData = {
      'label': label,
      'count': count,
      'timestamp': DateTime.now().toString(),
    };

    savedCounters.add(jsonEncode(counterData));
    await prefs.setStringList('saved_counters', savedCounters);
  }

  // Dialog to get label when saving count
  Future<void> _showSaveDialog() async {
    _labelController.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Counter'),
          content: TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Enter a label',
              hintText: 'e.g., Daily Steps, Meditation Count',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_labelController.text.isNotEmpty) {
                  _saveCounterWithLabel(_labelController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Counter saved successfully!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Dialog to get start value
  Future<void> _showStartValueDialog() async {
    _valueController.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Start Value'),
          content: TextField(
            controller: _valueController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter start value',
              hintText: 'e.g., 0, 10, 100',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_valueController.text.isNotEmpty) {
                  setState(() {
                    count = int.parse(_valueController.text);
                  });
                  _saveCounter();
                  Navigator.pop(context);
                }
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setEndValueDialog() async {
    _valueController.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set End Value for Alert'),
          content: TextField(
            controller: _valueController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter value',
              hintText: 'e.g. 10,75, 100',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_valueController.text.isNotEmpty) {
                  setState(() {
                    endValue = int.parse(_valueController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Set Alert'),
            ),
          ],
        );
      },
    );
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
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (endValue != null)
                Center(
                  child: Text("Alert Set to : $endValue"),
                ),
              Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 80),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (count == endValue) {
                          final player = AudioPlayer();
                          await player.setSource(AssetSource('error.mp3'));
                          await player.resume();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Counted till End Value!')),
                          );
                        }else {
                          setState(() {
                            count++;
                          });
                         await _saveCounter();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(60),
                        backgroundColor: Colors.black,
                      ),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 40),
                    ),
                    Positioned(
                      left: 80,
                      bottom: 10,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            count--;
                          });
                          _saveCounter(); // Save after decrement
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Colors.black,
                        ),
                        child: const Icon(Icons.remove,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: _showSaveDialog, // Show save dialog
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Save Count',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 120,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.black26,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/alphalogo.png",
                      height: 40,
                    ),
                    const Text(
                      "CounterPro",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.loop, color: Colors.black, size: 24.0),
                  SizedBox(width: 10),
                  Text('Reset Counter'),
                ],
              ),
              onTap: () {
                setState(() {
                  count = 0;
                  endValue = null;
                });
                _saveCounter();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.play_circle_outline,
                      color: Colors.black, size: 24.0),
                  SizedBox(width: 10),
                  Text('Set Start Value'),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                _showStartValueDialog();
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(
                    Icons.pause_circle_outline,
                    color: Colors.black,
                    size: 24.0,
                    semanticLabel: 'Reset',
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Set end value'),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                _setEndValueDialog();
              },
            ),
            ListTile(
                title: const Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: Colors.black,
                      size: 24.0,
                      semanticLabel: 'Reset',
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Saved Counters'),
                  ],
                ),
                onTap: () {
// Close the drawer first
                  Navigator.of(context).pop();
// Navigate to SavedCountersPage
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SavedCountersPage(),
                    ),
                  );
                }),
            // ... rest of your drawer items
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}
