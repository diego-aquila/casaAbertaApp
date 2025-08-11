// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/avaliacao.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'avaliacoes';

  // NOVA FUNÇÃO: Verificar se dispositivo já votou
  Future<bool> dispositivoJaVotou(String deviceId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('deviceId', isEqualTo: deviceId)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar dispositivo: $e');
      return false; // Em caso de erro, permite votar
    }
  }

  // NOVA FUNÇÃO: Verificar se dispositivo votou em oficina específica
  Future<bool> dispositivoJaVotouOficina(String deviceId, String oficina) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('deviceId', isEqualTo: deviceId)
          .where('oficina', isEqualTo: oficina)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar voto na oficina: $e');
      return false;
    }
  }

  // FUNÇÃO ATUALIZADA: Salvar com verificação
  Future<bool> salvarAvaliacaoComVerificacao(Avaliacao avaliacao) async {
    try {
      // Verifica se já votou
      final jaVotou = await dispositivoJaVotou(avaliacao.deviceId);
      if (jaVotou) {
        throw Exception('Este dispositivo já registrou uma avaliação');
      }

      await _firestore.collection(_collection).add(avaliacao.toMap());
      return true;
    } catch (e) {
      throw Exception('Erro ao salvar avaliação: $e');
    }
  }

  // Função original mantida para compatibilidade
  Future<void> salvarAvaliacao(Avaliacao avaliacao) async {
    await salvarAvaliacaoComVerificacao(avaliacao);
  }

  // Resto das funções permanecem iguais...
  Stream<List<Avaliacao>> obterAvaliacoes() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Avaliacao.fromMap(doc.data(), doc.id);
            } catch (e) {
              print('Erro ao processar documento ${doc.id}: $e');
              return null;
            }
          })
          .where((avaliacao) => avaliacao != null)
          .cast<Avaliacao>()
          .toList();
    });
  }

  Future<Map<String, dynamic>> obterEstatisticas() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();

      if (snapshot.docs.isEmpty) {
        return {
          'total': 0,
          'media': 0.0,
          'porOficina': <String, dynamic>{},
        };
      }

      final List<Avaliacao> avaliacoes = [];
      
      for (final doc in snapshot.docs) {
        try {
          final avaliacao = Avaliacao.fromMap(doc.data(), doc.id);
          avaliacoes.add(avaliacao);
        } catch (e) {
          print('❌ Erro ao processar documento ${doc.id}: $e');
        }
      }

      if (avaliacoes.isEmpty) {
        return {
          'total': 0,
          'media': 0.0,
          'porOficina': <String, dynamic>{},
        };
      }

      final Map<String, List<int>> porOficina = {};
      
      for (final avaliacao in avaliacoes) {
        porOficina.putIfAbsent(avaliacao.oficina, () => []);
        porOficina[avaliacao.oficina]!.add(avaliacao.nota);
      }

      final Map<String, dynamic> estatisticasPorOficina = {};
      
      porOficina.forEach((oficina, notas) {
        final media = notas.reduce((a, b) => a + b) / notas.length;
        estatisticasPorOficina[oficina] = {
          'total': notas.length,
          'media': media,
        };
      });

      final mediaGeral = avaliacoes
          .map((a) => a.nota)
          .reduce((a, b) => a + b) / avaliacoes.length;

      return {
        'total': avaliacoes.length,
        'media': mediaGeral,
        'porOficina': estatisticasPorOficina,
      };
    } catch (e) {
      throw Exception('Erro ao obter estatísticas: $e');
    }
  }
}