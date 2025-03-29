
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class AudioConverterService {


Future<String> copyAssetToTempDirectory(String assetPath) async {
  // Obtén los datos del archivo desde los assets
  ByteData data = await rootBundle.load(assetPath);
  
  // Crea una ruta temporal
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
  
  // Escribe el archivo de los assets en la ubicación temporal
  await tempFile.writeAsBytes(data.buffer.asUint8List());
  
  return tempFile.path;
}


Future<String> convertMp3ToWav(String assetPath) async {
  final inputPath = await copyAssetToTempDirectory(assetPath);
  final outputPath = '${(await getTemporaryDirectory()).path}/output_${DateTime.now().millisecondsSinceEpoch}.wav';

  // Comando optimizado para calidad de análisis de audio
  final cmd = '-y -i "$inputPath" -acodec pcm_s16le -ar 44100 -ac 1 -fflags +genpts "$outputPath"';

  try {
    final session = await FFmpegKit.execute(cmd);
    final rc = await session.getReturnCode();

    if (rc?.isValueSuccess() != true) {
      final logs = await session.getAllLogsAsString() ?? "No logs";
      await _cleanTempFiles(inputPath, outputPath);
      throw Exception('Error FFmpeg (${rc?.getValue()}): $logs');
    }

    if (!await File(outputPath).exists() || await File(outputPath).length() == 0) {
      throw Exception('Archivo de salida inválido');
    }

    return outputPath;
  } catch (e) {
    await _cleanTempFiles(inputPath, outputPath);
    rethrow;
  }
}

Future<void> _cleanTempFiles(String inputPath, String outputPath) async {
  try {
    await File(inputPath).delete();
    await File(outputPath).delete();
  } catch (_) {}
}



}
