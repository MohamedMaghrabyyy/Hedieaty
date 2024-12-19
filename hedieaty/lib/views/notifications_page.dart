import 'package:flutter/material.dart';
import 'package:hedieaty/models/notifications_model.dart';
import 'package:hedieaty/services/firestore_service.dart';

class NotificationsPage extends StatelessWidget {
  final String userId;

  const NotificationsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color.fromARGB(255, 58, 2, 80),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 58, 2, 80),
              Color.fromARGB(255, 219, 144, 5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<List<NotificationModel>>(
          stream: FirestoreService().streamNotifications(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Check if data is null or empty
            final notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
              return const Center(
                child: Text(
                  'No notifications found.',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              );
            }

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(context, notifications[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notification) {
    return Card(
      color: Colors.grey[200],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          notification.text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color.fromARGB(255, 58, 2, 80),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            await FirestoreService().deleteNotification(notification.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification deleted.')),
            );
          },
        ),
      ),
    );
  }
}

