// import 'package:flutter/material.dart';

// class AttendancePage extends StatefulWidget {
//   const AttendancePage({super.key});

//   @override
//   State<AttendancePage> createState() => _AttendancePageState();
// }

// class _AttendancePageState extends State<AttendancePage> {
//   final _nameController = TextEditingController();
//   String _workshopId = "1";
//   int _rating = 3; // Começa com 3 estrelas

//   // Future<void> _registerAttendance() async {
//   //   if (_nameController.text.isEmpty) return;

//   //   await FirebaseFirestore.instance.collection('presencas').add({
//   //     'participantName': _nameController.text,
//   //     'workshopId': _workshopId,
//   //     'rating': _rating,
//   //     'createdAt': FieldValue.serverTimestamp(),
//   //   });

//   //   _nameController.clear();
//   //   setState(() => _rating = 3);
//   // }

//   Widget _buildStar(int index) {
//     return IconButton(
//       icon: Icon(
//         index <= _rating ? Icons.star : Icons.star_border,
//         color: Colors.amber,
//         size: 32,
//       ),
//       onPressed: () {
//         setState(() {
//           _rating = index;
//         });
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Registrar Presença')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(labelText: "Nome do participante"),
//             ),
//             const SizedBox(height: 16),
//             DropdownButton<String>(
//               value: _workshopId,
//               items: const [
//                 DropdownMenuItem(value: "1", child: Text("Oficina 1")),
//                 DropdownMenuItem(value: "2", child: Text("Oficina 2")),
//               ],
//               onChanged: (v) => setState(() => _workshopId = v!),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(5, (index) => _buildStar(index + 1)),
//             ),
//             ElevatedButton(
//               onPressed: (){},
//                             // onPressed: _registerAttendance,

//               child: const Text("Registrar"),
//             ),
//             const SizedBox(height: 16),
//             const Expanded(child: AttendanceList()),
//           ],
//         ),
//       ),
//     );
//   }
// }

