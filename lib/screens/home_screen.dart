import 'package:avaliacao_stands/services/device_fingerprint.dart';
import 'package:flutter/material.dart';
import '../models/avaliacao.dart';
import '../services/firebase_service.dart';
import '../widgets/star_rating.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  
  String? _oficinaSelecionada;
  int _notaSelecionada = 0;
  bool _enviando = false;
  
  final List<String> _oficinas = [
    'Oficina de Programação',
    'Oficina de Design',
    'Oficina de Marketing',
    'Oficina de Empreendedorismo',
    'Oficina de Sustentabilidade',
    'Oficina de Inovação',
  ];

  // No método _enviarAvaliacao() da HomeScreen:

Future<void> _enviarAvaliacao() async {
  if (_oficinaSelecionada == null || _notaSelecionada == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor, selecione uma oficina e uma nota'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  setState(() {
    _enviando = true;
  });

  try {
    // NOVO: Gerar fingerprint do dispositivo
    final deviceId = await DeviceFingerprint.generate();
    print('🔍 Device ID: $deviceId');
    
    // NOVO: Verificar se já votou
    final jaVotou = await _firebaseService.dispositivoJaVotou(deviceId);
    if (jaVotou) {
      throw Exception('Este dispositivo já registrou uma avaliação anteriormente');
    }

    final avaliacao = Avaliacao(
      id: '',
      oficina: _oficinaSelecionada!,
      nota: _notaSelecionada,
      timestamp: DateTime.now(),
      deviceId: deviceId, // NOVO CAMPO
    );

    await _firebaseService.salvarAvaliacaoComVerificacao(avaliacao);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avaliação enviada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _oficinaSelecionada = null;
        _notaSelecionada = 0;
      });
    }
  } catch (e) {
    if (mounted) {
      Color backgroundColor = Colors.red;
      if (e.toString().contains('já registrou uma avaliação')) {
        backgroundColor = Colors.orange;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _enviando = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliação de Stands'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Avalie nossa oficina!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Selecione a oficina:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  DropdownButtonFormField<String>(
                    value: _oficinaSelecionada,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Escolha uma oficina',
                    ),
                    items: _oficinas.map((oficina) {
                      return DropdownMenuItem(
                        value: oficina,
                        child: Text(oficina),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _oficinaSelecionada = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Dê sua nota:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Center(
                    child: StarRating(
                      rating: _notaSelecionada,
                      onRatingChanged: (rating) {
                        setState(() {
                          _notaSelecionada = rating;
                        });
                      },
                      size: 50,
                    ),
                  ),
                  
                  if (_notaSelecionada > 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Nota selecionada: $_notaSelecionada estrela${_notaSelecionada > 1 ? 's' : ''}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _enviando ? null : _enviarAvaliacao,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: _enviando
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Enviando...'),
                            ],
                          )
                        : const Text('Enviar Avaliação'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}