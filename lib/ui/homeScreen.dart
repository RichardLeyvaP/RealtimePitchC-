import 'package:flutter/material.dart';
import 'package:singing_app/ui/realtimePitchScreen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: Text('Inicio')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navegar a RealtimePitchScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RealtimePitchScreen()),
            );
          },
          child: Text('Comenzar Afinación'),
        ),
      ),
      
    );
  }
}