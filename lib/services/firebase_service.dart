// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/visita.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'visitas';

  // Registrar visita à arena (sem verificação de duplicação)
  Future<bool> registrarVisita(Visita visita) async {
    try {
      await _firestore.collection(_collection).add(visita.toMap());
      return true;
    } catch (e) {
      throw Exception('Erro ao registrar visita: $e');
    }
  }

  // Obter stream de visitas em tempo real
  Stream<List<Visita>> obterVisitas() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Visita.fromMap(doc.data(), doc.id);
            } catch (e) {
              print('Erro ao processar documento ${doc.id}: $e');
              return null;
            }
          })
          .where((visita) => visita != null)
          .cast<Visita>()
          .toList();
    });
  }

  // Obter estatísticas das visitas por arena
  Future<Map<String, dynamic>> obterEstatisticas() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      if (snapshot.docs.isEmpty) {
        return {
          'total': 0,
          'porArena': <String, int>{},
        };
      }

      final List<Visita> visitas = [];

      for (final doc in snapshot.docs) {
        try {
          final visita = Visita.fromMap(doc.data(), doc.id);
          visitas.add(visita);
        } catch (e) {
          print('❌ Erro ao processar documento ${doc.id}: $e');
        }
      }

      if (visitas.isEmpty) {
        return {
          'total': 0,
          'porArena': <String, int>{},
        };
      }

      // Contabilizar visitas por arena
      final Map<String, int> porArena = {};

      for (final visita in visitas) {
        porArena[visita.arena] = (porArena[visita.arena] ?? 0) + 1;
      }

      return {
        'total': visitas.length,
        'porArena': porArena,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }
}
