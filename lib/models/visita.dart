// lib/models/visita.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Visita {
  final String id;
  final String arena;
  final DateTime timestamp;
  final String deviceId;

  Visita({
    required this.id,
    required this.arena,
    required this.timestamp,
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'arena': arena,
      'timestamp': Timestamp.fromDate(timestamp),
      'deviceId': deviceId,
    };
  }

  factory Visita.fromMap(Map<String, dynamic> map, String id) {
    DateTime timestamp;

    if (map['timestamp'] is Timestamp) {
      timestamp = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(map['timestamp']);
    } else {
      timestamp = DateTime.now();
    }

    return Visita(
      id: id,
      arena: map['arena'] ?? '',
      timestamp: timestamp,
      deviceId: map['deviceId'] ?? '',
    );
  }
}
