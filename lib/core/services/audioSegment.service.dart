

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:record/record.dart';

class AudioSegment {
  final String filePath;
  final DateTime timestamp;
  final int sequenceNumber;

  AudioSegment(this.filePath, this.timestamp, this.sequenceNumber);
}

class ContinuousAudioProcessor {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final Function(String) _onSegmentReady;
  bool _isRecording = false;
  int _segmentCounter = 0;
  Timer? _segmentTimer;
  String? _continuousFilePath;
  File? _continuousFile;
  IOSink? _audioSink;
  DateTime _lastSegmentTime = DateTime.now();
  final int _segmentDurationMs = 1000; // 1 segundo

  ContinuousAudioProcessor(this._onSegmentReady);

  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      // No necesitamos openRecorder con el paquete record
      final directory = await getTemporaryDirectory();
      _continuousFilePath = '${directory.path}/continuous_audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      // Inicializamos el archivo continuo
      _continuousFile = File(_continuousFilePath!);
      _audioSink = _continuousFile!.openWrite(mode: FileMode.writeOnly);
      
      // Configuramos el encabezado WAV
      await _writeWavHeader(_audioSink!);
      
      // Configuración para el paquete record
      final recordConfig = RecordConfig(
        encoder: AudioEncoder.wav, // Formato WAV
        sampleRate: 44100, // Frecuencia de muestreo estándar
        numChannels: 1, // Mono
        bitRate: 16, // 16 bits
      );
      
      await _audioRecorder.start(path:  _continuousFilePath!, recordConfig);

      _isRecording = true;
      _segmentCounter = 0;
      _lastSegmentTime = DateTime.now();

      // Timer para procesar segmentos
      _segmentTimer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
        if (!_isRecording) {
          timer.cancel();
          return;
        }

        final now = DateTime.now();
        final elapsed = now.difference(_lastSegmentTime).inMilliseconds;
        
        if (elapsed >= _segmentDurationMs) {
          _lastSegmentTime = now;
          await _processSegment();
        }
      });

    } catch (e) {
      print("Error al iniciar la grabación: $e");
      _isRecording = false;
      await _cleanup();
    }
  }

  Future<void> _processSegment() async {
    if (!_isRecording || _continuousFile == null) return;

    _segmentCounter++;
    final directory = await getTemporaryDirectory();
    final segmentPath = '${directory.path}/segment_${DateTime.now().millisecondsSinceEpoch}.wav';
    
    try {
      // 1. Cerramos temporalmente el archivo continuo para poder leerlo
      await _audioSink?.flush();
      await _audioSink?.close();
      
      // 2. Extraemos el último segundo de audio
      await _extractLastSecondToFile(_continuousFilePath!, segmentPath, _segmentDurationMs);
      
      // 3. Preparamos para seguir escribiendo
      _audioSink = _continuousFile!.openWrite(mode: FileMode.append);
      
      // 4. Notificamos el nuevo segmento
      _onSegmentReady(segmentPath);
      
    } catch (e) {
      print("Error procesando segmento: $e");
    }
  }


Future<void> stopRecording() async {
    if (!_isRecording) return;
    
    _isRecording = false;
    _segmentTimer?.cancel();
    
    try {
      await _audioRecorder.stop();
      await _audioSink?.flush();
      await _audioSink?.close();
      
      // Actualizamos el header WAV final
      await _updateWavHeader(_continuousFilePath!);
      
    } catch (e) {
      print("Error al detener la grabación: $e");
    } finally {
      await _cleanup();
    }
  }
  

  Future<void> _cleanup() async {
    try {
      await _audioSink?.close();
      _audioSink = null;
    } catch (e) {
      print("Error en cleanup: $e");
    }
  }

  Future<void> _writeWavHeader(IOSink sink) async {
    // Encabezado WAV vacío (se actualizará después)
    final header = List<int>.filled(44, 0);
    sink.add(header);
  }

  Future<void> _updateWavHeader(String filePath) async {
    final file = File(filePath);
    final data = await file.readAsBytes();
    
    if (data.length < 44) return; // Archivo demasiado corto
    
    // Actualizamos el tamaño del archivo en el encabezado
    final fileSize = data.length - 8;
    final dataSize = data.length - 44;
    
    final newData = Uint8List.fromList(data);
    
    // Escribimos los valores en little-endian
    newData.setRange(4, 8, [fileSize & 0xff, (fileSize >> 8) & 0xff, 
                          (fileSize >> 16) & 0xff, (fileSize >> 24) & 0xff]);
    
    newData.setRange(40, 44, [dataSize & 0xff, (dataSize >> 8) & 0xff, 
                             (dataSize >> 16) & 0xff, (dataSize >> 24) & 0xff]);
    
    await file.writeAsBytes(newData);
  }

  Future<void> _extractLastSecondToFile(String sourcePath, String targetPath, int durationMs) async {
    try {
      final sourceFile = File(sourcePath);
      final stats = await sourceFile.stat();
      final fileSize = stats.size;
      
      if (fileSize <= 44) return; // Solo tiene el encabezado
      
      // Parámetros del audio (asumiendo 16-bit mono a 44100Hz)
      const sampleRate = 44100;
      const bytesPerSample = 2; // 16-bit
      const numChannels = 1; // Mono
      const bytesPerSecond = sampleRate * bytesPerSample * numChannels;
      
      // Calculamos cuántos bytes necesitamos (1 segundo)
      int bytesToCopy = bytesPerSecond;
      final maxAvailable = fileSize - 44; // Restamos el encabezado
      
      if (bytesToCopy > maxAvailable) {
        bytesToCopy = maxAvailable;
      }
      
      // Leemos los últimos 'bytesToCopy' bytes del archivo fuente
      final sourceRandomAccess = await sourceFile.open();
      await sourceRandomAccess.setPosition(44); // Saltamos el encabezado
      
      final audioData = await sourceRandomAccess.read(bytesToCopy);
      await sourceRandomAccess.close();
      
      // Creamos el nuevo archivo WAV con el segmento
      final targetFile = File(targetPath);
      final sink = targetFile.openWrite();
      
      // Escribimos el encabezado WAV
      await _writeSegmentWavHeader(
        sink, 
        audioData.length, 
        sampleRate, 
        bytesPerSample, 
        numChannels
      );
      
      // Escribimos los datos de audio
      sink.add(audioData);
      await sink.close();
      
    } catch (e) {
      print("Error extrayendo segmento: $e");
      rethrow;
    }
  }

  Future<void> _writeSegmentWavHeader(
    IOSink sink, 
    int dataSize,
    int sampleRate,
    int bytesPerSample,
    int numChannels
  ) async {
    final byteRate = sampleRate * bytesPerSample * numChannels;
    final blockAlign = bytesPerSample * numChannels;
    final bitsPerSample = bytesPerSample * 8;
    final chunkSize = dataSize + 36;
    
    final header = Uint8List(44);
    final view = ByteData.view(header.buffer);
    
    // RIFF header
    header.setRange(0, 4, [0x52, 0x49, 0x46, 0x46]); // "RIFF"
    view.setUint32(4, chunkSize, Endian.little);
    header.setRange(8, 12, [0x57, 0x41, 0x56, 0x45]); // "WAVE"
    
    // fmt subchunk
    header.setRange(12, 16, [0x66, 0x6d, 0x74, 0x20]); // "fmt "
    view.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    view.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    view.setUint16(22, numChannels, Endian.little);
    view.setUint32(24, sampleRate, Endian.little);
    view.setUint32(28, byteRate, Endian.little);
    view.setUint16(32, blockAlign, Endian.little);
    view.setUint16(34, bitsPerSample, Endian.little);
    
    // data subchunk
    header.setRange(36, 40, [0x64, 0x61, 0x74, 0x61]); // "data"
    view.setUint32(40, dataSize, Endian.little);
    
    sink.add(header);
  }

  bool get isRecording => _isRecording;
}