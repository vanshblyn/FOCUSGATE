import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/mcq_gatekeeper_screen.dart';

void main() {
  runApp(const FocusGateApp());
}

class FocusGateApp extends StatelessWidget {
  const FocusGateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusGate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalSeconds = 25 * 60;
  Timer? timer;
  bool isRunning = false;
  bool isStrictAppLockOn = true;

  void toggleTimer() {
    if (isRunning) {
      timer?.cancel();
      setState(() => isRunning = false);
    } else {
      setState(() => isRunning = true);
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (totalSeconds > 0) {
          setState(() => totalSeconds--);
        } else {
          t.cancel();
          setState(() => isRunning = false);
        }
      });
    }
  }

  void openGatekeeperTest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => McqGatekeeperScreen(
          onUnlockSuccess: () {
            Navigator.of(ctx).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Verified! 15 Mins Entertainment Unlocked.'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  String formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('FocusGate', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.security, color: Color(0xFF00F2FE)),
            onPressed: openGatekeeperTest,
            tooltip: 'Test MCQ Gatekeeper',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00F2FE), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F2FE).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  formatTime(totalSeconds),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F2FE),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: toggleTimer,
              child: Text(
                isRunning ? 'PAUSE SESSION' : 'START FOCUS',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('App Gatekeeper Lock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Require 3 MCQs to open Insta/YT', style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  Switch(
                    value: isStrictAppLockOn,
                    activeColor: const Color(0xFFFFB800),
                    onChanged: (val) => setState(() => isStrictAppLockOn = val),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFB800),
                side: const BorderSide(color: Color(0xFFFFB800)),
              ),
              onPressed: openGatekeeperTest,
              icon: const Icon(Icons.quiz),
              label: const Text('Test MCQ Pop-up Gate Now'),
            )
          ],
        ),
      ),
    );
  }
}
