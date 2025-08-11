import 'package:flutter/material.dart';
import 'dart:async';
import '../models/avaliacao.dart';
import '../services/firebase_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  
  Timer? _refreshTimer;
  Map<String, dynamic>? _estatisticas;
  List<Avaliacao> _ultimasAvaliacoes = [];
  bool _carregando = true;
  
  @override
  void initState() {
    super.initState();
    _carregarDados();
    
    // Atualiza os dados a cada 3 segundos
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _carregarDados(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final stats = await _firebaseService.obterEstatisticas();
      
      if (mounted) {
        setState(() {
          _estatisticas = stats;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  Widget _buildEstatisticaCard(String titulo, String valor, IconData icone, Color cor) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 48, color: cor),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOficinaCard(String oficina, Map<String, dynamic> dados) {
    final media = dados['media'] as double;
    final total = dados['total'] as int;
    
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 200, // Altura fixa para manter uniformidade
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome da oficina (compacto)
            Text(
              oficina.replaceAll('Oficina de ', ''), // Remove "Oficina de" para economizar espaço
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 12),
            
            // Badge com número de votos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$total voto${total != 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            
            const Spacer(),
            
            // Estrelas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < media.round() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            
            const SizedBox(height: 8),
            
            // Nota centralizada
            Center(
              child: Text(
                media.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Barra de progresso
            LinearProgressIndicator(
              value: media / 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                media >= 4 ? Colors.green :
                media >= 3 ? Colors.orange : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final stats = _estatisticas ?? {};
    final totalVotos = stats['total'] as int? ?? 0;
    final mediaGeral = stats['media'] as double? ?? 0.0;
    final porOficina = stats['porOficina'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Dashboard de Resultados - Tempo Real',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.refresh, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Atualizado: ${DateTime.now().toString().substring(11, 19)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estatísticas Gerais
            Row(
              children: [
                Expanded(
                  child: _buildEstatisticaCard(
                    'Total de Votos',
                    totalVotos.toString(),
                    Icons.how_to_vote,
                    Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEstatisticaCard(
                    'Média Geral',
                    mediaGeral.toStringAsFixed(1),
                    Icons.star,
                    Colors.amber.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEstatisticaCard(
                    'Oficinas Avaliadas',
                    porOficina.length.toString(),
                    Icons.business,
                    Colors.green.shade600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Resultados por Oficina
            const Text(
              'Resultados por Oficina',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (porOficina.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma avaliação registrada ainda',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // Grid de resultados por oficina - máximo 2 linhas
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calcula quantos itens cabem por linha baseado na largura
                  final itemWidth = 280.0; // Largura de cada card
                  final itemsPerRow = (constraints.maxWidth / (itemWidth + 16)).floor().clamp(1, 6);
                  final totalItems = porOficina.length;
                  final rows = (totalItems / itemsPerRow).ceil().clamp(1, 2); // Máximo 2 linhas
                  final itemsInFirstRow = itemsPerRow;
                  final itemsInSecondRow = totalItems > itemsPerRow ? totalItems - itemsPerRow : 0;
                  
                  final oficinasEntries = porOficina.entries.toList();
                  
                  return Column(
                    children: [
                      // Primeira linha
                      SizedBox(
                        height: 220,
                        child: Row(
                          children: [
                            for (int i = 0; i < itemsInFirstRow && i < totalItems; i++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: _buildOficinaCard(
                                    oficinasEntries[i].key,
                                    oficinasEntries[i].value,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Segunda linha (se houver itens suficientes)
                      if (itemsInSecondRow > 0) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: Row(
                            children: [
                              for (int i = itemsInFirstRow; i < totalItems; i++)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: _buildOficinaCard(
                                      oficinasEntries[i].key,
                                      oficinasEntries[i].value,
                                    ),
                                  ),
                                ),
                              // Preenche espaços vazios se necessário para manter alinhamento
                              for (int i = itemsInSecondRow; i < itemsInFirstRow; i++)
                                const Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              
            const SizedBox(height: 32),
            
            // Últimas Avaliações em Tempo Real
            const Text(
              'Últimas Avaliações (Tempo Real)',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            StreamBuilder<List<Avaliacao>>(
              stream: _firebaseService.obterAvaliacoes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Erro ao carregar: ${snapshot.error}'),
                    ),
                  );
                }
                
                final avaliacoes = snapshot.data ?? [];
                
                if (avaliacoes.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Aguardando primeira avaliação...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                
                return Card(
                  child: Column(
                    children: avaliacoes.take(10).map((avaliacao) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Icons.star,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        title: Text(
                          avaliacao.oficina,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Há ${DateTime.now().difference(avaliacao.timestamp).inMinutes} minutos',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < avaliacao.nota ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              avaliacao.nota.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}