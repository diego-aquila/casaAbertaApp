import 'package:avaliacao_stands/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuração do Firebase para Web
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDCfa2mWRF4B0CFgBX3NcJ5u6RjIiu56XQ",
      authDomain: "casaabertaapp.firebaseapp.com",
      projectId: "casaabertaapp",
      storageBucket: "casaabertaapp.firebasestorage.app",
      messagingSenderId: "148657840815",
      appId: "1:148657840815:web:cd6866a3b7a34b4efeaa5a",
      measurementId: "G-1FFNM8TJD1",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (ontext) => const HomeScreen(),
        "/dashboard": (ontext) => const DashboardScreen(),
      },
      initialRoute: "/",
      title: 'Avaliação de Stands',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      // home: const DashboardScreen(),
    );
  }
}
