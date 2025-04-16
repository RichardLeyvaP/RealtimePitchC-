import 'dart:async';
import 'dart:io';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:singing_app/core/models/audioPitch.model.dart';
import 'package:singing_app/core/services/audioSegment.service.dart';
import 'package:singing_app/services/libraryNativa.service.dart';
import 'package:just_audio/just_audio.dart';

class AudioSyncController {
  final AudioPlayer _player = AudioPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final ContinuousAudioProcessor _audioProcessor;
  final LibraryNativaService _libraryService = LibraryNativaService();
  Function()? _onFinished;

  late DateTime _syncStartTime;
  double _currentPlaybackPos = 0;
  Timer? _syncTimer;
  List<AudioPitch> _backgroundPitches = [];
  Function(SyncEvaluation)? _onEvaluationUpdate;

  AudioSyncController(Function(String) onSegmentReady)
    : _audioProcessor = ContinuousAudioProcessor(onSegmentReady);

  Future<void> startSyncSession(
  String songPath,
  List<AudioPitch> backgroundPitches, {
  required Function(SyncEvaluation)? onEvaluationUpdate,
  Function()? onFinished, // ← NUEVO
}) async {
    _backgroundPitches = backgroundPitches;
    _onEvaluationUpdate = onEvaluationUpdate;
    _onFinished = onFinished; // ← GUARDAMOS EL CALLBACK
    _syncStartTime = DateTime.now();

    await Future.wait([
      _recorder.openRecorder(),
      _recorder.startRecorder(
        toFile: await _getTempRecordingPath(),
        codec: Codec.pcm16WAV,
        sampleRate: 44100,
      ),
      _audioProcessor.startRecording(),
    ]);

    await _player.setFilePath(songPath);

// Iniciar timer de sincronización *ANTES*
_syncTimer = Timer.periodic(const Duration(milliseconds: 50), _performSyncAnalysis);

// Comenzar a reproducir
await _player.play();

// Hacer un análisis inmediato después de un pequeño delay inicial
Future.delayed(const Duration(milliseconds: 100), () {
  _performSyncAnalysis(null); // asegúrate que acepte Timer? en la función
});

  }

  Future<void> stopSyncSession() async {
    _syncTimer?.cancel();
    await Future.wait([
      _player.stop(),
      _recorder.stopRecorder(),
      _audioProcessor.stopRecording(),
      _recorder.closeRecorder(),
    ]);
  }

  Future<String> _getTempRecordingPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/sync_recording_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  void _performSyncAnalysis(Timer? timer) async {
  try {
    final currentPosition = _player.position.inMilliseconds.toDouble();
    print('🔄 Player test - Posición del player: $currentPosition ms');
    _currentPlaybackPos = currentPosition;

   
   if (_player.playing == false ||
    (_player.duration != null && _player.position >= _player.duration!)) {
  print(' Audio finalizado, deteniendo grabación y análisis.');
  await stopSyncSession();
  _onFinished?.call(); // ← AQUÍ
  return;
}

    final bgPitches = _getBackgroundPitchesAt(_currentPlaybackPos);
    print('🔄 Player test - Pitches en la posición actual: ${bgPitches.length}');
    final latestRecordingPath = await _audioProcessor.getCurrentRecordingPath();

    if (latestRecordingPath != null && bgPitches.isNotEmpty) {
      final recordedPitches = await _libraryService.loadLibraryAssets(latestRecordingPath);
print('🔄 Player test - Pitches en la posición actual REcord: ${recordedPitches.length}');
    /*  final evaluation = await _libraryService.compareSyncedPitches(
        bgPitches,
        recordedPitches,
        _currentPlaybackPos,
      );
print('🎯 Evaluación generada: ${evaluation.positionMs}');
print('🎯 Callback existe: ${_onEvaluationUpdate != null}');
      _onEvaluationUpdate?.call(evaluation);*/
    }

    print('Posición actual: $_currentPlaybackPos ms');
  } catch (e) {
    print('Error en sync analysis: $e');
  }
}


  List<AudioPitch> _getBackgroundPitchesAt(double positionMs) {
    final positionSec = positionMs / 1000;
    return _backgroundPitches
        .where((pitch) =>
            pitch.startTime <= positionSec &&
            positionSec <= (pitch.startTime + pitch.duration))
        .toList();
  }

  double get currentPosition => _currentPlaybackPos;
  DateTime get syncStartTime => _syncStartTime;
}
