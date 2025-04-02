
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

  // 1. Asignar memoria para los arrays
  final bgArrayPtr = calloc<PitchResult>(background.length);
  final recArrayPtr = calloc<PitchResult>(recorded.length);

  // 2. Llenar el array de background
  for (int i = 0; i < background.length; i++) {
    final pitch = background[i].pitch;
    final duration = background[i].duration;
    final notePtr = background[i].note.toNativeUtf8();
    
    // Asignar valores directamente a la estructura
    bgArrayPtr[i].pitch = pitch;
    bgArrayPtr[i].duration = duration;
    bgArrayPtr[i].note = notePtr.cast<Char>(); // Cambiado a Char
    bgArrayPtr[i].startTime = 0;
    bgArrayPtr[i].amplitude = 1.0;
  }

  // 3. Llenar el array de recorded
  for (int i = 0; i < recorded.length; i++) {
    final pitch = recorded[i].pitch;
    final duration = recorded[i].duration;
    final notePtr = recorded[i].note.toNativeUtf8();
    
    recArrayPtr[i].pitch = pitch;
    recArrayPtr[i].duration = duration;
    recArrayPtr[i].note = notePtr.cast<Char>(); // Cambiado a Char
    recArrayPtr[i].startTime = 0;
    recArrayPtr[i].amplitude = 1.0;
  }

  // 4. Llamar a la función nativa
  final resultPtr = compareFunc(
    bgArrayPtr,
    background.length,
    recArrayPtr,
    recorded.length
  );

  // 5. Obtener resultado
  final result = resultPtr.toDartString();

  // 6. Liberar memoria
  _freePitchArray(bgArrayPtr, background.length);
  _freePitchArray(recArrayPtr, recorded.length);
  calloc.free(resultPtr);

  return result;
}

void _freePitchArray(Pointer<PitchResult> arrayPtr, int length) {
  for (int i = 0; i < length; i++) {
    final notePtr = arrayPtr[i].note;
    calloc.free(notePtr.cast<Utf8>());
  }
  calloc.free(arrayPtr);
}






}