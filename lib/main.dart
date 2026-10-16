import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_usage/app_usage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/mcq_gatekeeper_screen.dart';
import 'screens/app_selector_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int totalSeconds = 25 * 60;
  Timer? sessionTimer;
  Timer? blockerLoop;
  bool isRunning = false;
  bool isGatekeeperActive = true;
  DateTime? unlockedUntil;

  static const platform = MethodChannel('com.focusgate.app/system_settings');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startBackgroundWatcher();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    sessionTimer?.cancel();
    blockerLoop?.cancel();
    super.dispose();
  }

  // Blocker monitoring loop (Checks active foreground app every 1.5 seconds)
  void startBackgroundWatcher() {
    blockerLoop?.cancel();
    blockerLoop = Timer.periodic(const Duration(milliseconds: 1500), (t) async {
      if (!isGatekeeperActive) return;

      // If user recently cleared MCQs and has unlock grace period
      if (unlockedUntil != null && DateTime.now().isBefore(unlockedUntil!)) {
        return;
      }

      try {
        DateTime endDate = DateTime.now();
        DateTime startDate = endDate.subtract(const Duration(seconds: 4));
        List<AppUsageInfo> infos = await AppUsage().getAppUsage(startDate, endDate);

        if (infos.isEmpty) return;

        final prefs = await SharedPreferences.getInstance();
        final blocked = prefs.getStringList('blocked_apps') ?? [
          'com.instagram.android',
          'com.google.android.youtube',
        ];

        for (var info in infos) {
          if (blocked.contains(info.packageName) && info.usage.inSeconds > 0) {
            // Trigger Gatekeeper
            if (mounted) {
              triggerStrictGatekeeper();
            }
            break;
          }
        }
      } catch (_) {
        // Permission not granted or query failed
      }
    });
  }

  void triggerStrictGatekeeper() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => McqGatekeeperScreen(
          onUnlockSuccess: () {
            Navigator.of(ctx).pop();
            setState(() {
              unlockedUntil = DateTime.now().add(const Duration(minutes: 15));
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Verified! 15 Mins Pass Granted.'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void toggleTimer() {
    if (isRunning) {
      sessionTimer?.cancel();
      setState(() => isRunning = false);
    } else {
      setState(() => isRunning = true);
      sessionTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (totalSeconds > 0) {
          setState(() => totalSeconds--);
        } else {
          t.cancel();
          setState(() => isRunning = false);
        }
      });
    }
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
            icon: const Icon(Icons.apps_rounded, color: Color(0xFF00F2FE)),
            tooltip: 'Blocked Apps List',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AppSelectorScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shield, color: Color(0xFFFFB800)),
            tooltip: 'Test Gatekeeper',
            onPressed: triggerStrictGatekeeper,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 220,
              width: 220,
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
                  style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 35),
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
                      Text('Strict Gatekeeper Shield', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Auto-intercepts target apps', style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  Switch(
                    value: isGatekeeperActive,
                    activeColor: const Color(0xFFFFB800),
                    onChanged: (val) {
                      setState(() => isGatekeeperActive = val);
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00F2FE),
                side: const BorderSide(color: Color(0xFF00F2FE)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppSelectorScreen()),
                );
              },
              icon: const Icon(Icons.list_alt),
              label: const Text('Manage Blocked Apps List'),
            ),
          ],
        ),
      ),
    );
  }
}
