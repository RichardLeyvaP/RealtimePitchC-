import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:singing_app/core/bloc/pitch_cubit.dart';
import 'package:singing_app/core/models/audioPitch.model.dart';
import 'package:singing_app/core/services/audioSegment.service.dart';
import 'package:singing_app/core/services/requestPermissions.service.dart';
import 'package:singing_app/services/libraryNativa.service.dart';

class ConvertAudioPage extends StatefulWidget {
  @override
  _ConvertAudioPageState createState() => _ConvertAudioPageState();
}

class _ConvertAudioPageState extends State<ConvertAudioPage> {
  final List<String> audioFiles = [
    'assets/vocals/sample-3s.wav',
    'assets/vocals/sample-15s.wav',
    'assets/vocals/sample-12s.wav',
  ];
  List<AudioPitch> _backgroundPitches = [];
  String _currentEvaluation = "Presiona grabar para comenzar";

  LibraryNativaService libraryNativaService = LibraryNativaService();
  String? convertedFilePath;
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  late ContinuousAudioProcessor _audioProcessor;

  @override
  void initState() {
    super.initState();
    _audioProcessor = ContinuousAudioProcessor(_handleAudioSegment);
    requestPermissions().then((_) => _initAudio());
  }

  Future<void> _initAudio() async {
    try {
      await _audioRecorder.openRecorder();
      print("Grabador abierto correctamente");
    } catch (e) {
      print("Error al abrir el grabador: $e");
    }
  }

 Future<void> _handleAudioSegment(String segmentPath) async {
    try {
      final file = File(segmentPath);
      if (await file.exists() && await file.length() > 0) {
        List<AudioPitch> recordedPitches = await libraryNativaService.loadLibraryAssets(segmentPath);
        
        if (_backgroundPitches.isNotEmpty) {
          // Realizar comparación
          String evaluation = await libraryNativaService.comparePitches(
            _backgroundPitches,
            recordedPitches
          );
          
          setState(() {
            _currentEvaluation = evaluation;
          });
        }
        
        if (mounted) {
          context.read<PitchCubit>().addPitches(recordedPitches);
        }
        
        await file.delete();
      }
    } catch (e) {
      print("Error procesando segmento: $e");
    }
  }

    // Método para cargar la música de fondo
  Future<void> _loadBackgroundMusic(String path) async {
    _backgroundPitches = await libraryNativaService.loadLibrary(path);
    print("Música de fondo cargada con ${_backgroundPitches.length} notas");
  }

  Future<void> _startRecording() async {
    try {
      await _audioRecorder.openRecorder();
      setState(() => _isRecording = true);
     await _audioProcessor.startRecording();
    } catch (e) {
      print("Error al iniciar la grabación: $e");
      setState(() => _isRecording = false);
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioProcessor.stopRecording();
      await _audioRecorder.stopRecorder();
      setState(() => _isRecording = false);
    } catch (e) {
      print("Error al detener la grabación: $e");
    }
  }

  @override
  void dispose() {
    _audioProcessor.stopRecording();
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio'),
        actions: [
           IconButton(
          icon: Icon(
            _isRecording ? Icons.record_voice_over : Icons.record_voice_over_outlined,
            color: _isRecording ? Colors.red : Colors.black,
          ),
          onPressed: () {
            _isRecording ? _stopRecording() : _startRecording();
          },
        )
        ],
      ),
      body: Column(
        children: [
Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            _currentEvaluation,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getEvaluationColor(),
            ),
          ),
        ),
         Expanded(
          child: ListView.builder(
            itemCount: audioFiles.length,
            itemBuilder: (context, index) {
              String fileName = audioFiles[index].split('/').last;
              return ListTile(
                title: Text(fileName),
                trailing: Icon(Icons.audiotrack),
                onTap: () => _loadBackgroundMusic(audioFiles[index]),
              );
            },
          ),
        ),




        
        ],
      ),
    );
  }
  Color _getEvaluationColor() {
  switch (_currentEvaluation) {
    case "Afinado": return Colors.green;
    case "Desafinado": return Colors.red;
    case "Mas o menos": return Colors.orange;
    default: return Colors.black;
  }
  
}

}




