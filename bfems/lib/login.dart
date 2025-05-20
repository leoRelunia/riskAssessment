import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: const Color(0xFFF6F7F9),),
      body: const Center(child: Text('Login Content')),
    );
  }
}
