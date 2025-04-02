

import 'dart:async';
import 'dart:io';
import 'dart:math';
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

  // Future<void> _processSegment() async {


  //   if (!_isRecording || _continuousFile == null) return;

  //   _segmentCounter++;
  //   final directory = await getTemporaryDirectory();
  //   final segmentPath = '${directory.path}/segment_${DateTime.now().millisecondsSinceEpoch}.wav';
    
  //   try {
  //     // 1. Cerramos temporalmente el archivo continuo para poder leerlo
  //     await _audioSink?.flush();
  //     await _audioSink?.close();
      
  //     // 2. Extraemos el último segundo de audio
  //     //await _extractLastSecondToFile(_continuousFilePath!, segmentPath, _segmentDurationMs);
      
  //     // 3. Preparamos para seguir escribiendo
  //     _audioSink = _continuousFile!.openWrite(mode: FileMode.append);
      
  //     // 4. Notificamos el nuevo segmento
  //     _onSegmentReady(segmentPath);
      
  //   } catch (e) {
  //     print("Error procesando segmento: $e");
  //   }
  // }

  Future<void> _processSegment() async {
  if (!_isRecording || _continuousFile == null || _continuousFilePath == null) {
    return;
  }

  _segmentCounter++;
  final directory = await getTemporaryDirectory();
  final segmentPath = '${directory.path}/segment_${DateTime.now().millisecondsSinceEpoch}.wav';
  
  try {
    // 1. Cerrar y sincronizar el archivo
    await _safeCloseSink();

    // 2. Verificar que el archivo existe y tiene contenido
    final sourceFile = File(_continuousFilePath!);
    if (!await sourceFile.exists() || await sourceFile.length() <= 44) {
      print("Archivo fuente no válido");
      return;
    }

    // 3. Extraer segmento de audio
    await _extractLastSecondToFile(_continuousFilePath!, segmentPath, _segmentDurationMs);

    // 4. Reabrir el archivo para continuar grabando
    await _safeReopenSink();

    // 5. Procesar el segmento
    if (await File(segmentPath).exists()) {
      _onSegmentReady(segmentPath);
    }

  } catch (e, stack) {
    print("Error en _processSegment: $e");
    print("Stack trace: $stack");
    await _safeReopenSink(); // Intentar recuperar la grabación
  }
}

Future<void> _safeCloseSink() async {
  try {
    await _audioSink?.flush();
    await _audioSink?.close();
    _audioSink = null;
  } catch (e) {
    print("Error cerrando sink: $e");
  }
}

Future<void> _safeReopenSink() async {
  try {
    if (_continuousFile != null) {
      _audioSink = _continuousFile!.openWrite(mode: FileMode.append);
    }
  } catch (e) {
    print("Error reabriendo sink: $e");
    // Intentar recrear el archivo si falla
    if (_continuousFilePath != null) {
      _continuousFile = File(_continuousFilePath!);
      _audioSink = _continuousFile!.openWrite(mode: FileMode.append);
    }
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
  File? sourceFile;
  RandomAccessFile? sourceRaf;
  IOSink? targetSink;
  
  try {
    sourceFile = File(sourcePath);
    final fileSize = await sourceFile.length();
    
    if (fileSize <= 44) {
      print("Archivo demasiado pequeño para contener datos de audio");
      return;
    }

    // Parámetros del audio (16-bit mono a 44100Hz)
    const sampleRate = 44100;
    const bytesPerSample = 2;
    const numChannels = 1;
    const bytesPerSecond = sampleRate * bytesPerSample * numChannels;

    // Calcular posición de inicio (último segundo)
    int bytesToCopy = min(bytesPerSecond, fileSize - 44);
    int startPos = max(44, fileSize - bytesToCopy - 44);

    // Abrir archivos con manejo seguro
    sourceRaf = await sourceFile.open(mode: FileMode.read);
    await sourceRaf.setPosition(startPos);

    // Leer datos en bloques para evitar sobrecarga de memoria
    const blockSize = 4096; // 4KB por bloque
    final targetFile = File(targetPath);
    targetSink = targetFile.openWrite();

    // Escribir encabezado WAV
    await _writeSegmentWavHeader(
      targetSink,
      bytesToCopy,
      sampleRate,
      bytesPerSample,
      numChannels
    );

    // Copiar datos en bloques
    int remaining = bytesToCopy;
    while (remaining > 0) {
      final chunkSize = min(blockSize, remaining);
      final chunk = await sourceRaf.read(chunkSize);
      if (chunk.isEmpty) break;
      
      targetSink.add(chunk);
      remaining -= chunk.length;
    }

    // Asegurar escritura completa
    await targetSink.flush();
    
  } catch (e, stack) {
    print("Error crítico en _extractLastSecondToFile: $e");
    print("Stack trace: $stack");
    throw Exception("Error procesando segmento de audio");
  } finally {
    // Cerrar recursos en orden inverso a su apertura
    try {
      await targetSink?.close();
    } catch (e) {
      print("Error cerrando targetSink: $e");
    }
    
    try {
      await sourceRaf?.close();
    } catch (e) {
      print("Error cerrando sourceRaf: $e");
    }
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