
import 'package:path_provider/path_provider.dart';
import 'package:singing_app/core/bloc/pitch_cubit.dart';
import 'package:singing_app/core/models/audioPitch.model.dart';
import 'package:singing_app/core/models/pitchResult.model.dart';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

typedef AnalyzeWavFunc = Pointer<PitchResult> Function(Pointer<Utf8>, Pointer<Int32>);
typedef AnalyzeWav = Pointer<PitchResult> Function(Pointer<Utf8>, Pointer<Int32>);

typedef FreeResultsFunc = Void Function(Pointer<PitchResult>, Int32);
typedef FreeResults = void Function(Pointer<PitchResult>, int);


typedef ComparePitchesFunc = Pointer<Utf8> Function(
  Pointer<PitchResult>, Int32, Pointer<PitchResult>, Int32, Int32); // 👈 nativo

typedef ComparePitches = Pointer<Utf8> Function(
  Pointer<PitchResult>, int, Pointer<PitchResult>, int, int);    

const kSyncPrecisionMs = 50; // Margen de sincronización en milisegundos
class LibraryNativaService {

  // Función para obtener la nota como String
String getNoteFromPitchResult(PitchResult result) {
  return result.note.cast<Utf8>().toDartString();
}
  

Future<String> copyAssetToTemp2(String assetPath) async {
  // Cargar el archivo de los assets como bytes
  final ByteData data = await rootBundle.load(assetPath);

  // Convertir los bytes en una lista de enteros
  final List<int> bytes = data.buffer.asUint8List();

  // Validar si el archivo tiene una cabecera WAV válida
  if (bytes.length < 12) {
    print("El archivo es demasiado pequeño para ser un WAV válido.");
  } else {
    String header = String.fromCharCodes(bytes.sublist(0, 4));
    String format = String.fromCharCodes(bytes.sublist(8, 12));
    print("Cabecera: $header, Formato: $format");

    if (header != "RIFF" || format != "WAVE") {
      print("El archivo no es un WAV válido.");
    } else {
      print("El archivo es un WAV válido.");
    }
  }

  // Usar los bytes directamente para crear un archivo temporal
  final Directory tempDir = await getTemporaryDirectory();
  final File tempFile = File('${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.wav');

  // Escribir los bytes en el archivo temporal
  await tempFile.writeAsBytes(bytes, flush: true);

  // Retornar la ruta del archivo temporal
  return tempFile.path;
}

   // Cargar la biblioteca compartida
  Future<List<AudioPitch>> loadLibrary(String pathWav) async {
  String tempFilePath = await copyAssetToTemp2(pathWav);

  final dylib = DynamicLibrary.open('libnative-lib.so');
  final analyzeWav = dylib.lookupFunction<AnalyzeWavFunc, AnalyzeWav>('analyzeWav');
  final freeResults = dylib.lookupFunction<FreeResultsFunc, FreeResults>('freeResults');

  final resultCount = calloc<Int32>();
  final filePathPtr = tempFilePath.toNativeUtf8();  

final file = File(tempFilePath);
print("🛠 Verificando archivo WAV...");

if (await file.exists()) {
  print("✅ Archivo existe. Tamaño: ${(await file.length())} bytes");

  RandomAccessFile raf = await file.open(mode: FileMode.read);
  Uint8List header = await raf.read(12); // Leer los primeros 12 bytes
  await raf.close();

  print("📄 Cabecera del archivo: ${String.fromCharCodes(header)}");
} else {
  print("❌ El archivo no existe.");
}

  final resultsPtr = analyzeWav(filePathPtr, resultCount);
  final count = resultCount.value;
List<AudioPitch> newPitches = [];
  if (count > 0) {
   

for (int i = 0; i < count; i++) {
  final result = resultsPtr.elementAt(i).ref;


 final startTime = result.startTime;
final duration = result.duration;
final endTime = startTime + duration;

newPitches.add(AudioPitch(
  result.pitch,
  getNoteFromPitchResult(result),
  duration,
  startTime,
  endTime, 
  result.amplitude, 
));

  
  print("Nota: ${getNoteFromPitchResult(result)} - Pitch: ${result.pitch} Hz - Duración: ${result.duration} sec");
}



     freeResults(resultsPtr, count);
  calloc.free(resultCount);
  calloc.free(filePathPtr);
    return newPitches;
  }
  else{
     freeResults(resultsPtr, count);
  calloc.free(resultCount);
  calloc.free(filePathPtr);
    return newPitches;
  } 
  }

  // Cargar la biblioteca compartida
  Future<List<AudioPitch>> loadLibraryAssets(String pathWav) async {
  String tempFilePath = pathWav;

  final dylib = DynamicLibrary.open('libnative-lib.so');
  final analyzeWav = dylib.lookupFunction<AnalyzeWavFunc, AnalyzeWav>('analyzeWav');
  final freeResults = dylib.lookupFunction<FreeResultsFunc, FreeResults>('freeResults');

  final resultCount = calloc<Int32>();
  final filePathPtr = tempFilePath.toNativeUtf8();  

final file = File(tempFilePath);
print("🛠 Verificando archivo WAV...");

if (await file.exists()) {
  print("✅ Archivo grabado existe. Tamaño: ${(await file.length())} bytes");

  RandomAccessFile raf = await file.open(mode: FileMode.read);
  Uint8List header = await raf.read(12); // Leer los primeros 12 bytes
  await raf.close();

  print("📄 Cabecera  del Archivo grabado: ${String.fromCharCodes(header)}");
} else {
  print("❌ El  Archivo grabado no existe.");
}

  final resultsPtr = analyzeWav(filePathPtr, resultCount);
  final count = resultCount.value;
List<AudioPitch> newPitches = [];
  if (count > 0) {
   


for (int i = 0; i < count; i++) {
  final result = resultsPtr.elementAt(i).ref;
   final startTime = result.startTime;
final duration = result.duration;
final endTime = startTime + duration;
  newPitches.add(AudioPitch(
     result.pitch,
     getNoteFromPitchResult(result),
     result.duration,
     result.startTime,
     endTime,
     result.amplitude  
  ));
}



     freeResults(resultsPtr, count);
  calloc.free(resultCount);
  calloc.free(filePathPtr);
    return newPitches;
  }
  else{
     freeResults(resultsPtr, count);
  calloc.free(resultCount);
  calloc.free(filePathPtr);
    return newPitches;
  }

 
  }



Future<String> comparePitches(List<AudioPitch> background, List<AudioPitch> recorded) async {
  final dylib = DynamicLibrary.open('libnative-lib.so');
  final compareFunc = dylib.lookupFunction<ComparePitchesFunc, ComparePitches>('comparePitches');

  // 1. Asignar memoria
  final bgArrayPtr = calloc<PitchResult>(background.length);
  final recArrayPtr = calloc<PitchResult>(recorded.length);

  try {
    // 2. Llenar arrays
    for (int i = 0; i < background.length; i++) {
  final notePtr = background[i].note.toNativeUtf8();

  bgArrayPtr[i]
    ..pitch = background[i].pitch
    ..duration = background[i].duration
    ..note = notePtr.cast<Utf8>()
    ..startTime = background[i].startTime 
    ..amplitude = background[i].amplitude;
  // Debug print
  print('Segmento comparar - bg[$i] => '
        'pitch: ${background[i].pitch}, '
        'note: ${background[i].note}, '
        'startTime: ${background[i].startTime}, '
        'endTime: ${background[i].startTime + background[i].duration}, '
        'duration: ${background[i].duration}, '
        'amplitude: ${background[i].amplitude}'
        );

}

    for (int i = 0; i < recorded.length; i++) {
      final notePtr = recorded[i].note.toNativeUtf8();
      recArrayPtr[i]
        ..pitch = recorded[i].pitch
        ..duration = recorded[i].duration
        ..note = notePtr.cast<Utf8>()
        ..startTime = recorded[i].startTime
        ..amplitude = recorded[i].amplitude;

         // Debug print
  print('Segmento comparar - rc[$i] => '
        'pitch: ${recorded[i].pitch}, '
        'note: ${recorded[i].note}, '
        'startTime: ${recorded[i].startTime}, '
        'endTime: ${recorded[i].startTime + recorded[i].duration}, '
        'duration: ${recorded[i].duration}, '
        'amplitude: ${recorded[i].amplitude}'
        );
    }

    // 3. Llamar a función nativa
    final resultPtr = compareFunc(
      bgArrayPtr,
      background.length,
      recArrayPtr,
      recorded.length,
       1 // nivel este es 1-facil, 2-mas o menos o 3-profesional
    );  
    

    // 4. Convertir resultado
    final result = resultPtr.toDartString();
    
    return result;
  } finally {
    // 5. Liberar memoria
    _freePitchArray(bgArrayPtr, background.length);
    _freePitchArray(recArrayPtr, recorded.length);
  }
}


void _freePitchArray(Pointer<PitchResult> arrayPtr, int length) {
  for (int i = 0; i < length; i++) {
    final notePtr = arrayPtr[i].note;
    if (notePtr != nullptr) {
      calloc.free(notePtr.cast<Utf8>());
    }
  }
  calloc.free(arrayPtr);
}
Future<SyncEvaluation> compareSyncedPitches(
  List<AudioPitch> background,
  List<AudioPitch> recorded,
  double positionMs,
) async {
  // Convertir la posición a segundos:
  final positionSec = positionMs / 1000;
  // Definir la ventana de 0.5 segundos (ajustable según necesidad)
  final double startWindow = positionSec;
  final double endWindow = positionSec + 0.5;

  final bgSegment = _getPitchesBetween(background, startWindow, endWindow);
  final recSegment = _getPitchesBetween(recorded, startWindow, endWindow);

  print('BG Segment at $positionSec: ${bgSegment.length} notas');
  print('REC Segment at $positionSec: ${recSegment.length} notas');

  if (bgSegment.isEmpty || recSegment.isEmpty) {
    return SyncEvaluation.empty();
  }

  final result = await comparePitches(bgSegment, recSegment);
  return SyncEvaluation.fromNative(result, positionMs);
}
List<AudioPitch> _getPitchesBetween(List<AudioPitch> pitches, double startSec, double endSec) {
  return pitches.where((pitch) {
    final pitchStart = pitch.startTime;
    final pitchEnd = pitch.startTime + pitch.duration;
    return (pitchStart < endSec && pitchEnd > startSec);
  }).toList();
}


 /*Future<SyncEvaluation> compareSyncedPitches(
    List<AudioPitch> background,
    List<AudioPitch> recorded,
    double positionMs,
  ) async {
    final bgSegment = _extractSyncSegment(background, positionMs);
    final recSegment = _extractSyncSegment(recorded, positionMs);

print('ESTEESTEST2-BG Segment at $positionMs: ${bgSegment.length}');
print('ESTEESTEST2-REC Segment at $positionMs: ${recSegment.length}');



    if (bgSegment.isEmpty || recSegment.isEmpty) {
      return SyncEvaluation.empty();
    }

    final result = await comparePitches(bgSegment, recSegment);
    print('ESTEESTEST2-comparePitches result: $result');

    return SyncEvaluation.fromNative(result, positionMs);
  }*/

 List<AudioPitch> _extractSyncSegment(List<AudioPitch> pitches, double positionMs) {
    final positionSec = positionMs / 1000;
    return pitches.where((pitch) {
      final endTime = pitch.startTime + pitch.duration;
      return (pitch.startTime - positionSec).abs() <= (kSyncPrecisionMs / 1000) ||
             (endTime - positionSec).abs() <= (kSyncPrecisionMs / 1000);
    }).toList();
  }
 

}

// NUEVO: Clase para manejar resultados
  class SyncEvaluation {
    final double accuracy;
    final double timingDiff;
    final double positionMs;
    final String feedback;

    SyncEvaluation({
      required this.accuracy,
      required this.timingDiff,
      required this.positionMs,
      required this.feedback,
    });

   factory SyncEvaluation.fromNative(String nativeResult, double positionMs) {
  try {
    final parts = nativeResult.split('|');
    return SyncEvaluation(
      accuracy: double.parse(parts[0]),
      timingDiff: double.parse(parts[1]),
      positionMs: positionMs,
      feedback: parts[2],
    );
  } catch (e) {
    print('Error parsing native result: $nativeResult -> $e');
    return SyncEvaluation.empty();
  }
}


    factory SyncEvaluation.empty() => SyncEvaluation(
      accuracy: 0,
      timingDiff: 0,
      positionMs: 0,
      feedback: "No comparable segments",
    );
  }