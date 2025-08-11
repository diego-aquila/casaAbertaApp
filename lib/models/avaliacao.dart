// lib/models/avaliacao.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Avaliacao {
  final String id;
  final String oficina;
  final int nota;
  final DateTime timestamp;
  final String deviceId; // NOVO CAMPO

  Avaliacao({
    required this.id,
    required this.oficina,
    required this.nota,
    required this.timestamp,
    required this.deviceId, // NOVO CAMPO
  });

  Map<String, dynamic> toMap() {
    return {
      'oficina': oficina,
      'nota': nota,
      'timestamp': Timestamp.fromDate(timestamp),
      'deviceId': deviceId, // NOVO CAMPO
    };
  }

  factory Avaliacao.fromMap(Map<String, dynamic> map, String id) {
    DateTime timestamp;
    
    if (map['timestamp'] is Timestamp) {
      timestamp = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(map['timestamp']);
    } else {
      timestamp = DateTime.now();
    }
    
    return Avaliacao(
      id: id,
      oficina: map['oficina'] ?? '',
      nota: (map['nota'] ?? 0).toInt(),
      timestamp: timestamp,
      deviceId: map['deviceId'] ?? '', // NOVO CAMPO
    );
  }
}