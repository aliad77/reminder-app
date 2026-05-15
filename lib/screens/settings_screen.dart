import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notificationSound = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _notificationSound = prefs.getBool('notification_sound') ?? true;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _darkMode = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }

  Future<void> _toggleNotificationSound(bool value) async {
    setState(() => _notificationSound = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_sound', value);
  }

  Future<void> _sendTestNotification() async {
    await NotificationService().showTestNotification();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Test notification sent!'),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _clearAllReminders() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Reminders'),
        content: const Text(
            'This will permanently delete all your reminders. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await StorageService().clearAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All reminders cleared.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.alarm, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('RemindMe'),
          ],
        ),
        content: const Text(
          'RemindMe is a personal reminder app that helps you stay on top of '
          'your schedule. Set reminders, get notifications, and never miss '
          'an important moment again.\n\nBuilt with Flutter.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.deepPurple),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark/light theme'),
            value: _darkMode,
            activeThumbColor: Colors.deepPurple,
            onChanged: _toggleDarkMode,
          ),
          const Divider(),
          const _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            secondary:
                const Icon(Icons.volume_up, color: Colors.deepPurple),
            title: const Text('Notification Sound'),
            subtitle: const Text('Play sound with notifications'),
            value: _notificationSound,
            activeThumbColor: Colors.deepPurple,
            onChanged: _toggleNotificationSound,
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active,
                color: Colors.deepPurple),
            title: const Text('Send Test Notification'),
            subtitle: const Text('Verify notifications are working'),
            trailing: ElevatedButton(
              onPressed: _sendTestNotification,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Send'),
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text('Clear All Reminders'),
            subtitle: const Text('Delete all saved reminders'),
            trailing: ElevatedButton(
              onPressed: _clearAllReminders,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Clear'),
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.deepPurple),
            title: Text('App Version'),
            trailing: Text(
              '1.0.0',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.help_outline, color: Colors.deepPurple),
            title: const Text('About'),
            subtitle: const Text('Learn more about RemindMe'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
