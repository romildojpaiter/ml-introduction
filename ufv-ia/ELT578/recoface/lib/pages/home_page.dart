import 'package:flutter/material.dart';
import 'package:recoface/pages/face_recognition/face_detector_page.dart';
import 'package:recoface/pages/face_scan/face_scan_screen.dart';
import 'package:recoface/pages/users_page.dart';
import 'package:recoface/utils/local_db.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Recoface Project",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildButton(
            text: 'Found Faces',
            icon: Icons.face,
            onClicked: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FaceDetectorPage()));
            },
          ),
          const SizedBox(height: 24),
          buildButton(
            text: 'Registro',
            icon: Icons.app_registration_rounded,
            onClicked: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FaceScanScreen()));
            },
          ),
          const SizedBox(height: 24),
          buildButton(
            text: 'Login',
            icon: Icons.login,
            onClicked: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FaceScanScreen(user: LocalDb.getUser())));
            },
          ),
          const SizedBox(height: 24),
          buildButton(
            text: 'Usuários',
            icon: Icons.person,
            onClicked: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UsersPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      SizedBox(
        width: double.infinity, // <-- Your width
        height: 50, // <-- Your height
        child: ElevatedButton.icon(
          onPressed: onClicked,
          icon: Icon(icon, size: 26),
          label: Text(
            text,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );
}
