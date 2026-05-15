import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/storage_service.dart';

class DetailScreen extends StatefulWidget {
  final Reminder? reminder;

  const DetailScreen({super.key, this.reminder});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Reminder _reminder;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _reminder = widget.reminder!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Reminder) {
      _reminder = args;
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _reminder = _reminder.copyWith(isFavorite: !_reminder.isFavorite);
    });

    final reminders = await _storage.loadReminders();
    final index = reminders.indexWhere((r) => r.id == _reminder.id);
    if (index != -1) {
      reminders[index] = _reminder;
      await _storage.saveReminders(reminders);
    }
  }

  Future<void> _deleteReminder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content:
            const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final reminders = await _storage.loadReminders();
    reminders.removeWhere((r) => r.id == _reminder.id);
    await _storage.saveReminders(reminders);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Detail'),
        actions: [
          IconButton(
            icon: Icon(
              _reminder.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _reminder.isFavorite ? Colors.red.shade200 : Colors.white,
            ),
            onPressed: _toggleFavorite,
            tooltip: _reminder.isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.title, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _reminder.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.description_outlined,
                            color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _reminder.description,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text(
                          _formatDateTime(_reminder.dateTime),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          _reminder.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _reminder.isFavorite
                              ? Colors.red
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _reminder.isFavorite
                              ? 'Saved to favorites'
                              : 'Not in favorites',
                          style: TextStyle(
                            fontSize: 14,
                            color: _reminder.isFavorite
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _deleteReminder,
                icon: const Icon(Icons.delete_outline),
                label: const Text(
                  'Delete Reminder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $hour:$minute $ampm';
  }
}
