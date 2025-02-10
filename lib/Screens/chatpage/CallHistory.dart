import 'package:flutter/material.dart';

class CallHistoryPage extends StatefulWidget {
  const CallHistoryPage({super.key});

  @override
  CallHistoryPageState createState() => CallHistoryPageState();
}

class CallHistoryPageState extends State<CallHistoryPage> {
  final List<Map<String, dynamic>> callHistory = [
    {
      'name': 'Alice',
      'image': 'https://via.placeholder.com/150',
      'type': 'video',
      'duration': '02:30',
      'time': DateTime.now().subtract(Duration(minutes: 30))
    },
    {
      'name': 'Bob',
      'image': 'https://via.placeholder.com/150',
      'type': 'audio',
      'duration': '05:12',
      'time': DateTime.now().subtract(Duration(hours: 1, minutes: 15))
    },
    {
      'name': 'Charlie',
      'image': 'https://via.placeholder.com/150',
      'type': 'video',
      'duration': '10:45',
      'time': DateTime.now().subtract(Duration(days: 1, hours: 2))
    },
  ];

  String timeAgo(DateTime time) {
    final Duration difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call History')),
      body: ListView.builder(
        itemCount: callHistory.length,
        itemBuilder: (context, index) {
          final call = callHistory[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(call['image']),
            ),
            title: Text(call['name'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                '${call['type'].toUpperCase()} call • ${call['duration']} • ${timeAgo(call['time'])}'),
            trailing: Icon(
              call['type'] == 'video' ? Icons.videocam : Icons.call,
              color: Colors.green,
            ),
          );
        },
      ),
    );
  }
}
