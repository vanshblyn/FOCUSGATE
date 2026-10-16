import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSelectorScreen extends StatefulWidget {
  const AppSelectorScreen({super.key});

  @override
  State<AppSelectorScreen> createState() => _AppSelectorScreenState();
}

class _AppSelectorScreenState extends State<AppSelectorScreen> {
  List<AppInfo> apps = [];
  Set<String> blockedPackages = {'com.instagram.android', 'com.google.android.youtube'};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadApps();
  }

  Future<void> loadApps() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('blocked_apps');
    if (saved != null) {
      blockedPackages = saved.toSet();
    }

    try {
      List<AppInfo> installed = await InstalledApps.getInstalledApps(true, true);
      installed.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      if (mounted) {
        setState(() {
          apps = installed;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> toggleApp(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (blockedPackages.contains(packageName)) {
        blockedPackages.remove(packageName);
      } else {
        blockedPackages.add(packageName);
      }
    });
    await prefs.setStringList('blocked_apps', blockedPackages.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        title: const Text('Target Apps to Lock', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00F2FE)))
          : apps.isEmpty
              ? const Center(child: Text('No apps found', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    final isBlocked = blockedPackages.contains(app.packageName);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isBlocked ? const Color(0xFFFFB800) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: app.icon != null
                            ? Image.memory(app.icon!, width: 40, height: 40)
                            : const Icon(Icons.android, color: Colors.white),
                        title: Text(app.name ?? 'App', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(app.packageName, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        trailing: Switch(
                          activeColor: const Color(0xFFFFB800),
                          value: isBlocked,
                          onChanged: (_) => toggleApp(app.packageName),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
