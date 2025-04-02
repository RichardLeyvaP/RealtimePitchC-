
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
    Pointer<PitchResult>, Int32, Pointer<PitchResult>, Int32);
typedef ComparePitches = Pointer<Utf8> Function(
    Pointer<PitchResult>, int, Pointer<PitchResult>, int);

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
  newPitches.add(AudioPitch(
    result.pitch,
    getNoteFromPitchResult(result),
    result.duration,
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
  newPitches.add(AudioPitch(
    result.pitch,
    getNoteFromPitchResult(result),
    result.duration,
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
        ..startTime = 0
        ..amplitude = 1.0;
    }

    for (int i = 0; i < recorded.length; i++) {
      final notePtr = recorded[i].note.toNativeUtf8();
      recArrayPtr[i]
        ..pitch = recorded[i].pitch
        ..duration = recorded[i].duration
        ..note = notePtr.cast<Utf8>()
        ..startTime = 0
        ..amplitude = 1.0;
    }

    // 3. Llamar a función nativa
    final resultPtr = compareFunc(
      bgArrayPtr,
      background.length,
      recArrayPtr,
      recorded.length
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



Pointer<PitchResult> _allocatePitchArray(int length) {
  final ptr = calloc<PitchResult>(length);
  if (ptr == nullptr) {
    throw Exception("No se pudo asignar memoria para PitchResult array");
  }
  return ptr;
}

void _fillPitchArray(Pointer<PitchResult> arrayPtr, List<AudioPitch> pitches) {
  for (int i = 0; i < pitches.length; i++) {
    final pitch = pitches[i];
    final notePtr = pitch.note.toNativeUtf8();
    
    // Asignación segura
    arrayPtr[i].pitch = pitch.pitch;
    arrayPtr[i].duration = pitch.duration;
    arrayPtr[i].note = notePtr.cast<Utf8>();
    arrayPtr[i].startTime = 0;
    arrayPtr[i].amplitude = 1.0;
  }
}

Pointer<Utf8> _safeNativeCall(
  ComparePitches func,
  Pointer<PitchResult> bgPtr,
  int bgLength,
  Pointer<PitchResult> recPtr,
  int recLength,
) {
  try {
    final resultPtr = func(bgPtr, bgLength, recPtr, recLength);
    if (resultPtr == nullptr) {
      throw Exception("La función nativa devolvió un puntero nulo");
    }
    return resultPtr;
  } catch (e) {
    throw Exception("Error en llamada nativa: ${e.toString()}");
  }
}

String _parseNativeResult(Pointer<Utf8> resultPtr) {
  try {
    final result = resultPtr.toDartString();
    calloc.free(resultPtr);
    return result;
  } catch (e) {
    calloc.free(resultPtr);
    return "Error parseando resultado";
  }
}

void _safeFreePitchArray(Pointer<PitchResult> arrayPtr, int length) {
  try {
    if (arrayPtr != nullptr) {
      for (int i = 0; i < length; i++) {
        final notePtr = arrayPtr[i].note;
        if (notePtr != nullptr) {
          calloc.free(notePtr.cast<Utf8>());
        }
      }
      calloc.free(arrayPtr);
    }
  } catch (e) {
    print("Error liberando memoria: $e");
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





}