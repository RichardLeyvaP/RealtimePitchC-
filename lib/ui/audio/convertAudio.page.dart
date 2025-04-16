import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:singing_app/core/controllers/audio_sync_controller.dart';
import 'package:singing_app/core/models/audioPitch.model.dart';
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
  double? _currentScore;
  String? _selectedSongPath;
  bool _isSyncing = false;
  String _syncStatus = "Listo";
  double _currentPosition = 0;

  late AudioSyncController _syncController;
  LibraryNativaService _libraryService = LibraryNativaService();

  @override
  void initState() {
    super.initState();
    _syncController = AudioSyncController(_handleAudioSegment);
    _backgroundPitches = [];
  }
Future<void> _handleAudioSegment(String segmentPath) async {
  final file = File(segmentPath);

  if (await file.exists() && await file.length() > 0) {
    // Cargar las notas grabadas desde el archivo del segmento
    List<AudioPitch> recordedPitches =
        await _libraryService.loadLibraryAssets(segmentPath);

    final double startTime = _currentPosition / 1000; // tiempo actual en segundos
    final double endTime = startTime + 0.5;

    // Desplazar las notas grabadas al tiempo global (opcional, si es necesario)
    for (var pitch in recordedPitches) {
      pitch.startTime += startTime;
    }

    final backgroundSegment = _getBackgroundPatchesBetween(startTime, endTime);

    // Logs detallados
    print("🟡 Música de fondo cargada con - Tiempo de análisis: [$startTime - $endTime] seg");

    for (final pitch in backgroundSegment) {
      print("Segmento grabado - CANCION ▶️ ${pitch.pitch} (${pitch.startTime.toStringAsFixed(3)} - ${(pitch.startTime + pitch.duration).toStringAsFixed(3)}s)");
    }

    print("🎤 Segmento grabado:");
    for (final pitch in recordedPitches) {
      print("Segmento grabado 🎧 ${pitch.pitch} (${pitch.startTime.toStringAsFixed(3)} - ${(pitch.startTime + pitch.duration).toStringAsFixed(3)}s)");
    }

    if (backgroundSegment.isNotEmpty && recordedPitches.isNotEmpty) {
      final evaluation = await _libraryService.comparePitches(
        backgroundSegment,
        recordedPitches,
      );

      setState(() {
        _currentEvaluation = evaluation;
        _syncStatus = evaluation;
      });
    } else {
      print("⚠️ No hay notas suficientes para comparar.");
    }

    // Limpiar el archivo temporal
    await file.delete();
  } else {
    print("❌ Archivo de segmento no encontrado o vacío.");
  }
}

List<AudioPitch> _getBackgroundPatchesBetween(double startSec, double endSec) {
  return _backgroundPitches.where((pitch) {
    final pitchStart = pitch.startTime;
    final pitchEnd = pitch.startTime + pitch.duration;

    // Incluye notas que estén parcial o totalmente dentro del rango
    return pitchEnd > startSec && pitchStart < endSec;
  }).toList();
}


  Future<String> getAssetPath(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    return tempFile.path;
  }

  Future<void> _startSync() async {
    if (_selectedSongPath == null || _backgroundPitches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecciona una canción")),
      );
      setState(() => _currentEvaluation = "Selecciona una canción primero");
      return;
    }

    final songPath = await getAssetPath(_selectedSongPath!);
    setState(() => _isSyncing = true);

    await _syncController.startSyncSession(
      songPath,
      _backgroundPitches,
      onEvaluationUpdate: (evaluation) {
        print("Evaluación1: ${evaluation.feedback}");
        print("Evaluación2: ${evaluation.positionMs}");
        setState(() {
          _currentEvaluation = evaluation.feedback;
          _currentScore = evaluation.accuracy;
          _currentPosition = evaluation.positionMs;
        });
      },
      onFinished: () {
        setState(() {
          _isSyncing = false;
          _currentEvaluation = _syncStatus = "Finalizado";
        });
      },
    );
  }

  Future<void> _stopSync() async {
    setState(() => _isSyncing = false);
    await _syncController.stopSyncSession();
  }

  Future<void> _loadBackgroundMusic(String path) async {
    _selectedSongPath = path;
    _backgroundPitches = await _libraryService.loadLibrary(path);
    for (var pitch in _backgroundPitches) {
      print("Música de fondo cargada con - Nota: ${pitch.note}, Frecuencia: ${pitch.pitch}, Duración: ${pitch.duration} , Inicio: ${pitch.startTime} , Fin: ${pitch.endTime} , Amplitud: ${pitch.amplitude}");
    }
    setState(() {});
  }

  @override
  void dispose() {
    _syncController.stopSyncSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Karaoke'),
        actions: [
          IconButton(
            icon: Icon(
              _isSyncing ? Icons.stop : Icons.play_arrow,
              color: _isSyncing ? Colors.red : Colors.black,
            ),
            onPressed: _isSyncing ? _stopSync : _startSync,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: _buildEvaluationDisplay(),
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
          _buildSyncControls(),
          _buildSyncStatus(),
        ],
      ),
    );
  }

  Widget _buildEvaluationDisplay() {
    return Column(
      children: [
        Text(
          _currentEvaluation,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _getEvaluationColor(),
          ),
        ),
        if (_currentScore != null)
          Text(
            'Precisión: ${(_currentScore! * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blueGrey,
            ),
          ),
      ],
    );
  }

  Color _getEvaluationColor() {
    switch (_currentEvaluation) {
      case "Afinado":
        return Colors.green;
      case "Desafinado":
        return Colors.red;
      case "Mas o menos":
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  Widget _buildSyncControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(_isSyncing ? Icons.stop : Icons.play_arrow),
          onPressed: _isSyncing ? _stopSync : _startSync,
          color: _isSyncing ? Colors.red : Colors.green,
          iconSize: 40,
        ),
      ],
    );
  }

  Widget _buildSyncStatus() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            _syncStatus,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Posición actual: ${(_currentPosition / 1000).toStringAsFixed(1)}s',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
