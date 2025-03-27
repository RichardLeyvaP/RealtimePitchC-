import 'dart:io';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';


Future<String> extractPitchFromAudio(String assetPath) async {
  final wavPath = await convertAssetMp3ToWav(assetPath);
  final pitch = await getPitchFromWav(wavPath);
  print('Pitch: $pitch');
  return pitch?.toStringAsFixed(2) ?? 'N/A';
}


Future<String> convertAssetMp3ToWav(String assetPath) async {
  // 1️⃣ Obtener directorio interno
  final dir = await getApplicationDocumentsDirectory();
  String mp3Path = '${dir.path}/temp_audio.mp3';
  String wavPath = '${dir.path}/output.wav';

  // 2️⃣ Copiar archivo de assets a almacenamiento interno
  ByteData data = await rootBundle.load(assetPath);
  List<int> bytes = data.buffer.asUint8List();
  File(mp3Path).writeAsBytesSync(bytes);

  // 3️⃣ Convertir a WAV usando FFmpeg
  await FFmpegKit.execute('-i $mp3Path -ac 1 -ar 44100 $wavPath');
print('wavPath: $wavPath');
  return wavPath;
}


Future<double?> getPitchFromWav(String wavPath) async {
  final tempDir = await getTemporaryDirectory();
  final logFile = File('${tempDir.path}/pitch_log.txt');

  // Ejecutar FFmpeg sin redirigir la salida a un archivo, lo haremos manualmente
  final session = await FFmpegKit.execute(
    '-i $wavPath -af astats=metadata=1:reset=1 -f null -',
  );

 


  // Obtener el código de retorno, la salida estándar y la salida de error
  final returnCode = await session.getReturnCode();
  final output = await session.getOutput();
  final errorOutput = await session.getAllLogs();

  // Verifica si el comando FFmpeg fue exitoso
  if (returnCode?.getValue() != ReturnCode.success) {
    print('Error: $errorOutput');
    return null;
  }

  // Escribir los logs de FFmpeg en el archivo
 var writeAsString = await logFile.writeAsString('Output: $output\nError Output: $errorOutput');
 print('writeAsString: $writeAsString');

  // Esperar un poco para asegurar que el archivo de log se haya escrito
  await Future.delayed(Duration(seconds: 2)); 

  // Leer el archivo de log
  if (await logFile.exists()) {
    print('Log file created at: ${logFile.path}');
    final logContent = await logFile.readAsString();
    print('logContent: ${logContent}');
    
    // Buscar la frecuencia media en el log
    final pitchMatch = RegExp(r"Mean frequency:\s+([\d.]+)").firstMatch(logContent);
    print('pitchMatch: $pitchMatch');
    if (pitchMatch != null) {
      return double.tryParse(pitchMatch.group(1)!);
    }
  } else {
    print('Log file not found.');
  }

  return null;
}



/*
Future<double?> getPitchFromWav(String wavPath) async {
  final tempDir = await getTemporaryDirectory();
  final logFile = File('${tempDir.path}/pitch_log.txt');

  // Comando de FFmpeg para analizar el audio y redirigir la salida de log
  final session = await FFmpegKit.execute(
    '-i $wavPath -af astats=metadata=1:reset=1 -f null - > ${logFile.path} 2>&1'
  );

  // Obtener el código de retorno, la salida estándar y la de error
  final returnCode = await session.getReturnCode();
  final output = await session.getOutput();
  final errorOutput = await session.getAllLogs();

  print('Return code: $returnCode');
  print('Output: $output');
  print('Error Output: $errorOutput');
  print('Expected log file path: ${logFile.path}');

  // Esperar un poco para asegurar que el archivo de log se haya escrito
  await Future.delayed(Duration(seconds: 1));

  // Leer el archivo de log
  if (await logFile.exists()) {
    print('Log file created at: ${logFile.path}');
    final logContent = await logFile.readAsString();

    // Buscar la frecuencia media en el log
    final pitchMatch = RegExp(r"Mean frequency:\s+([\d.]+)").firstMatch(logContent);
    if (pitchMatch != null) {
      return double.tryParse(pitchMatch.group(1)!);
    }
  } else {
    print('Log file not found.');
  }

  return null;
}*/


