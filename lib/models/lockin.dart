// lib/models/lockin.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class LockIn {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String frequency;      // e.g., 'daily' or 'mon,wed,fri'
  final String reminderTime;   // '08:00' in 24h format (store as string for now)
  final DateTime createdAt;

  LockIn({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.frequency,
    required this.reminderTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'frequency': frequency,
      'reminderTime': reminderTime,
      'createdAt': createdAt,
    };
  }

  factory LockIn.fromMap(String id, Map<String, dynamic> data) {
    return LockIn(
      id: id,
      userId: data['userId'],
      title: data['title'],
      description: data['description'],
      frequency: data['frequency'],
      reminderTime: data['reminderTime'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  LockIn copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? frequency,
    String? reminderTime,
    DateTime? createdAt,
  }) {
    return LockIn(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class LockInInstance {
  final String id;
  final DateTime scheduledFor;
  final DateTime? completedAt;
  final String? mediaUrl;
  final String status; // "pending", "completed", or "missed"

  LockInInstance({
    required this.id,
    required this.scheduledFor,
    this.completedAt,
    this.mediaUrl,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'scheduledFor': scheduledFor,
      'completedAt': completedAt,
      'mediaUrl': mediaUrl,
      'status': status,
    };
  }

  factory LockInInstance.fromMap(String id, Map<String, dynamic> data) {
    return LockInInstance(
      id: id,
      scheduledFor: (data['scheduledFor'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      mediaUrl: data['mediaUrl'],
      status: data['status'],
    );
  }
}
