import 'package:flutter/material.dart';
import 'dart:async';
import '../models/visita.dart';
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
  bool _carregando = true;

  // Cores das arenas (mesmo esquema da HomeScreen)
  final Map<String, Color> _coresArenas = {
    'deu planta': Colors.green,
    'deu game': Colors.purple,
    'deu link': Colors.blue,
    'deu curto': Colors.orange,
    'deu alerta': Colors.red,
    'deu cena': Colors.pink,
    'deu pixel': Colors.cyan,
  };

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

  Widget _buildGraficoBarras() {
    final porArena = _estatisticas?['porArena'] as Map<String, dynamic>? ?? {};

    if (porArena.isEmpty) {
      return Card(
        child: Container(
          height: 600,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Nenhuma visita registrada ainda',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Encontrar o valor máximo para normalizar as barras
    final maxVisitas = porArena.values
        .fold<int>(0, (max, current) => current > max ? current as int : max);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Visitas por Arena',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Gráfico de barras
            Container(
              height: 400,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _coresArenas.keys.map((arena) {
                  final visitas = porArena[arena] as int? ?? 0;
                  final altura =
                      maxVisitas > 0 ? (visitas / maxVisitas) * 250 : 0.0;
                  final cor = _coresArenas[arena]!;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Número de visitas acima da barra
                          if (visitas > 0)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: cor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                visitas.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                          // Barra
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                            height: altura.clamp(20.0, 250.0),
                            decoration: BoxDecoration(
                              color: cor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: cor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Nome da arena (horizontal)
                          SizedBox(
                            height: 60,
                            child: Center(
                              child: Text(
                                arena.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoEstatisticas() {
    final totalVisitas = _estatisticas?['total'] as int? ?? 0;
    final porArena = _estatisticas?['porArena'] as Map<String, dynamic>? ?? {};
    final arenasVisitadas = porArena.length;

    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.people,
                    size: 48,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    totalVisitas.toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const Text(
                    'Total de Visitas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.place,
                    size: 48,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    arenasVisitadas.toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const Text(
                    'Arenas Visitadas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Informações de Visitas às Arenas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade600,
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
            // Resumo das estatísticas
            _buildResumoEstatisticas(),

            const SizedBox(height: 32),

            // Gráfico de barras
            _buildGraficoBarras(),
          ],
        ),
      ),
    );
  }
}
