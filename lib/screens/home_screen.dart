import 'package:flutter/material.dart';
import '../models/visita.dart';
import '../services/firebase_service.dart';
import '../services/device_fingerprint.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  bool _enviando = false;

  // Definição das arenas com suas cores e imagens
  final List<Map<String, dynamic>> _arenas = [
    {
      'nome': 'deu planta',
      'cor': Colors.green,
      'imagem':
          'assets/images/deuPlanta.png', // Substitua pelo caminho da sua imagem
    },
    {
      'nome': 'deu game',
      'cor': Colors.purple,
      'imagem': 'assets/images/deuGame.png',
    },
    {
      'nome': 'deu link',
      'cor': Colors.blue,
      'imagem': 'assets/images/deuLink.png',
    },
    {
      'nome': 'deu curto',
      'cor': Colors.orange,
      'imagem': 'assets/images/deuCurto.png',
    },
    {
      'nome': 'deu alerta',
      'cor': Colors.red,
      'imagem': 'assets/images/deuAlerta.png',
    },
    {
      'nome': 'deu cena',
      'cor': Colors.pink,
      'imagem': 'assets/images/deuCena.png',
    },
    {
      'nome': 'deu pixel',
      'cor': Colors.cyan,
      'imagem': 'assets/images/deuPixel.png',
    },
  ];

  Future<void> _registrarVisita(String arena) async {
    setState(() {
      _enviando = true;
    });

    try {
      // Gerar fingerprint do dispositivo
      final deviceId = await DeviceFingerprint.generate();
      print('🔍 Device ID: $deviceId');

      final visita = Visita(
        id: '',
        arena: arena,
        timestamp: DateTime.now(),
        deviceId: deviceId,
      );

      await _firebaseService.registrarVisita(visita);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Visita registrada na arena "$arena"!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao registrar visita: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
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

  Widget _buildArenaButton(String nome, Color cor, String imagemPath) {
    return Container(
      width: 120,
      height: 120,
      child: ElevatedButton(
        onPressed: _enviando ? null : () => _registrarVisita(nome),
        style: ElevatedButton.styleFrom(
          // backgroundColor: Colors.transparent,
          // foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: cor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(imagemPath),
              fit: BoxFit.cover,
              // colorFilter: ColorFilter.mode(
              //   cor.withOpacity(0.7), // Overlay da cor da arena
              //   BlendMode.overlay,
              // ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // gradient: LinearGradient(
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              //   colors: [
              //     Colors.transparent,
              //     Colors.black
              //         .withOpacity(0.6), // Gradiente para melhor legibilidade
              //   ],
              // ),
            ),
            padding: const EdgeInsets.all(16),
            // child: Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     // Icon(
            //     //   _getArenaIcon(nome),
            //     //   size: 40,
            //     //   color: Colors.white,
            //     //   shadows: [
            //     //     Shadow(
            //     //       color: Colors.black.withOpacity(0.5),
            //     //       blurRadius: 4,
            //     //       offset: const Offset(0, 2),
            //     //     ),
            //     //   ],
            //     // ),
            //     const SizedBox(height: 12),
            //     // Text(
            //     //   nome.toUpperCase(),
            //     //   textAlign: TextAlign.center,
            //     //   style: const TextStyle(
            //     //     fontSize: 16,
            //     //     fontWeight: FontWeight.bold,
            //     //     letterSpacing: 1.2,
            //     //     color: Colors.white,
            //     //     shadows: [
            //     //       Shadow(
            //     //         color: Colors.black,
            //     //         blurRadius: 4,
            //     //         offset: Offset(0, 2),
            //     //       ),
            //     //     ],
            //     //   ),
            //     // ),
            //   ],
            // ),
          ),
        ),
      ),
    );
  }

  IconData _getArenaIcon(String arena) {
    switch (arena) {
      case 'deu planta':
        return Icons.local_florist;
      case 'deu game':
        return Icons.sports_esports;
      case 'deu link':
        return Icons.link;
      case 'deu curto':
        return Icons.movie;
      case 'deu alerta':
        return Icons.warning;
      case 'deu cena':
        return Icons.theater_comedy;
      case 'deu pixel':
        return Icons.grid_on;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'Registro de Visitas',
      //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: const Color(0xFFfef6ea),
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      // ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Container(
            color: const Color(0xFFfef6ea),
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                // Header
                Center(
                  child: Image.asset('assets/images/header.png'),
                ),
                const Text("Selecione a Arena e registre a visita!"),
                // Grid de Arenas
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _arenas.length,
                      itemBuilder: (context, index) {
                        final arena = _arenas[index];
                        return _buildArenaButton(
                          arena['nome'] as String,
                          arena['cor'] as Color,
                          arena['imagem'] as String,
                        );
                      },
                    ),
                  ),
                ),

                // Loading indicator
                if (_enviando)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text(
                          'Registrando visita...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Informação sobre visitas
                // Card(
                //   color: Colors.green.shade50,
                //   child: Padding(
                //     padding: const EdgeInsets.all(16),
                //     child: Row(
                //       children: [
                //         Icon(
                //           Icons.check_circle_outline,
                //           color: Colors.green.shade600,
                //         ),
                //         const SizedBox(width: 12),
                //         Expanded(
                //           child: Text(
                //             'Você pode registrar quantas visitas quiser em qualquer arena!',
                //             style: TextStyle(
                //               color: Colors.green.shade800,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
