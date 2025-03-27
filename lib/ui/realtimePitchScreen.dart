import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:record/record.dart';
import 'package:singing_app/core/services/audio.service.dart';

class RealtimePitchScreen extends StatefulWidget {
  @override
  _RealtimePitchScreenState createState() => _RealtimePitchScreenState();
}

class _RealtimePitchScreenState extends State<RealtimePitchScreen> {
  final AudioRecorder _record = AudioRecorder();  // Usa AudioRecorder en lugar de Record
  List<String> notes = [];
  AudioService audioService = AudioService();



  Future<void> _startRecording() async {
  // Obtener una ruta válida para guardar el archivo de audio
  final audioPath = await audioService.getAudioPath();
  // Iniciar la grabación
  await _record.start(
    const RecordConfig(),
    path: audioPath,  // Usar la ruta generada
  );

  // Enviar chunks de audio cada segundo
  while (await _record.isRecording()) {
    await Future.delayed(Duration(seconds: 1));
    await _record.stop();
    await _sendAudioChunk(audioPath);
    await _record.start(
      const RecordConfig(),
      path: audioPath,  // Continuar grabando en el mismo archivo
    );
  }
}

  Future<void> _sendAudioChunk(String audioPath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:5000/realtime_pitch'),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      audioPath,
      contentType: MediaType('audio', 'wav'),
    ));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final pitchData = jsonDecode(responseData);
    print('NOTAAAAAAAAAAAAAAAAAAAAAAAAAAA:${pitchData['note']}');

    setState(() {
      notes.add(pitchData['note']?? "Silence");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Afinador en Tiempo Real')),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(notes[index]),
            tileColor: _getNoteColor(notes[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startRecording,
        child: Icon(Icons.mic),
      ),
    );
  }

  Color _getNoteColor(String note) {
    // Cambia el color según si la nota es correcta o no
    if (note == "C4") return Colors.green;
    if (note == "Silence") return Colors.grey;
    return Colors.red;
  }
}