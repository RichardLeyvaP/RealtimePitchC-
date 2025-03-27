

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

base class PitchResult extends Struct {
  @Double()
  external double pitch;
  
  @Double()
  external double duration;
  
  external Pointer<Utf8> note;
}

// Función para obtener la nota como String
String getNoteFromPitchResult(PitchResult result) {
  return result.note.toDartString();
}

typedef AnalyzeWavFunc = Pointer<PitchResult> Function(Pointer<Utf8>, Pointer<Int32>);
typedef AnalyzeWav = Pointer<PitchResult> Function(Pointer<Utf8>, Pointer<Int32>);

typedef FreeResultsFunc = Void Function(Pointer<PitchResult>, Int32);
typedef FreeResults = void Function(Pointer<PitchResult>, int);

class AudioPitch {
  final double pitch;
  final String note;
  final double duration;

  AudioPitch(this.pitch, this.note, this.duration);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String tempFilePath = await copyAssetToTemp('assets/vocals/sample-15s.wav');

  final dylib = DynamicLibrary.open('libnative-lib.so');
  final analyzeWav = dylib.lookupFunction<AnalyzeWavFunc, AnalyzeWav>('analyzeWav');
  final freeResults = dylib.lookupFunction<FreeResultsFunc, FreeResults>('freeResults');

  final resultCount = calloc<Int32>();
  final filePathPtr = tempFilePath.toNativeUtf8();

  final resultsPtr = analyzeWav(filePathPtr, resultCount);
  final count = resultCount.value;

  List<AudioPitch> pitches = [];
  if (count > 0) {
    for (int i = 0; i < count; i++) {
      final result = resultsPtr.elementAt(i).ref;
      pitches.add(AudioPitch(
        result.pitch,
        getNoteFromPitchResult(result),
        result.duration,
      ));
    }
  }

  freeResults(resultsPtr, count);
  calloc.free(resultCount);
  calloc.free(filePathPtr);

  runApp(MyApp(pitches));
}

Future<String> copyAssetToTemp(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  final Directory tempDir = await getTemporaryDirectory();
  final File tempFile = File('${tempDir.path}/HEALTH_CHECK.wav');
  await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
  return tempFile.path;
}

class MyApp extends StatelessWidget {
  final List<AudioPitch> pitches;

  MyApp(this.pitches);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Audio Pitch Analyzer")),
        body: ListView.builder(
          itemCount: pitches.length,
          itemBuilder: (context, index) {
            final pitch = pitches[index];
            return ListTile(
              title: Text("Note: ${pitch.note}"),
              subtitle: Text("Pitch: ${pitch.pitch.toStringAsFixed(2)} Hz - Duration: ${pitch.duration.toStringAsFixed(4)} sec"),
            );
          },
        ),
      ),
    );
  }
}


























// import 'dart:ffi'; // Para FFI
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:ffi/ffi.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';




// typedef AnalyzeWavFunc = Void Function(Pointer<Utf8>, Pointer<Double>, Pointer<Double>, Pointer<Int32>);
// typedef AnalyzeWav = void Function(Pointer<Utf8>, Pointer<Double>, Pointer<Double>, Pointer<Int32>);

// class AudioPitch {
//   final double pitch;
//   final String note;
//   final double duration;

//   AudioPitch(this.pitch, this.note, this.duration);
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   String tempFilePath = await copyAssetToTemp('assets/vocals/HEALTH_CHECK.wav');

//   final dylib = DynamicLibrary.open('libnative-lib.so'); // Nombre de la biblioteca C++
//   final analyzeWav = dylib.lookupFunction<AnalyzeWavFunc, AnalyzeWav>('analyzeWav');

//   // Crear punteros para los resultados
//   final pitchResults = calloc.allocate<Double>(1000);
//   final durationResults = calloc.allocate<Double>(1000);
//   final countResults = calloc.allocate<Int32>(1);

//   // Llamamos a la función C++ que analiza el archivo WAV
//   analyzeWav(tempFilePath.toNativeUtf8(), pitchResults, durationResults, countResults);

//   // Verificar que el número de resultados es correcto
//   int count = countResults.value;
//   print('Cantidad de resultados: $count'); // Depuración

//   // Leer los resultados desde la memoria asignada
//   List<AudioPitch> pitches = [];
//   for (int i = 0; i < count; i++) {
//     double pitch = pitchResults[i];
//     double duration = durationResults[i];
//     String note = getNoteFromPitch(pitch);

//     // Verificar cada valor de pitch, note y duration
//     print('Pitch $i: $pitch Hz, Note: $note, Duration: $duration sec'); // Depuración

//     pitches.add(AudioPitch(pitch, note, duration));
//   }

//   // Liberar memoria una vez que ya no la necesitamos
//   calloc.free(pitchResults);
//   calloc.free(durationResults);
//   calloc.free(countResults);

//   runApp(MyApp(pitches));
// }

// String getNoteFromPitch(double pitch) {
//   // Aquí puedes utilizar la lógica que ya tienes para convertir el pitch a una nota musical
//   return "A4"; // Por ejemplo, por simplicidad
// }

// Future<String> copyAssetToTemp(String assetPath) async {
//   final ByteData data = await rootBundle.load(assetPath);
//   final Directory tempDir = await getTemporaryDirectory();
//   final File tempFile = File('${tempDir.path}/HEALTH_CHECK.wav');
//   await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
//   print('Archivo copiado a: ${tempFile.path}');
//   return tempFile.path;
// }


// class MyApp extends StatelessWidget {
//   final List<AudioPitch> pitches;

//   MyApp(this.pitches);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text("Flutter + C++")),
//         body: Center(
//           child: Column(
//             children: [
//               Text("Archivo de audio procesado"),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: pitches.length,
//                   itemBuilder: (context, index) {
//                     final pitch = pitches[index];
//                     return ListTile(
//                       title: Text("Pitch: ${pitch.pitch} Hz"),
//                       subtitle: Text("Note: ${pitch.note}\nDuration: ${pitch.duration} sec"),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }































// Future<void> main() async {
//    // Aseguramos que el binding esté inicializado
//   WidgetsFlutterBinding.ensureInitialized();
//   await requestPermissions();
//   setupDependencies();
//   runApp(SingingApp());
// }



// Future<void> main() async {
//   //    // Aseguramos que el binding esté inicializado
//   WidgetsFlutterBinding.ensureInitialized();
//   await requestPermissions();
//   setupDependencies();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Afinador en Tiempo Real',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: HomeScreen(),  // Define HomeScreen como la pantalla inicial
//     );
//   }
// }

/************************************************************************************************* */

/*
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karaoke App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: KaraokeScreen(),
    );
  }
}

class KaraokeScreen extends StatefulWidget {
  @override
  _KaraokeScreenState createState() => _KaraokeScreenState();
}

class _KaraokeScreenState extends State<KaraokeScreen> {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  double _currentPitch = 0.0;
  double _expectedPitch = 440.0; // Frecuencia de la nota La4 (440 Hz)

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioRecorder.openRecorder(); // Abre el grabador
    await _audioPlayer.setAsset('assets/vocals/MIA_MIA_MIA.mp3'); // Asegúrate de agregar un archivo de música en assets
  }

  Future<void> _startRecording() async {
    await _audioRecorder.startRecorder(
      toFile: 'audio.aac', // Cambia la extensión del archivo según el códec
      codec: Codec.aacADTS, // Usa un códec compatible
    );
    setState(() => _isRecording = true);

    // Escucha los datos de audio en tiempo real
    _audioRecorder.onProgress!.listen((RecordingDisposition disposition) {
      // Aquí puedes procesar los datos de audio
      _analyzeAudio();
    });
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stopRecorder();
    setState(() => _isRecording = false);
  }

  void _analyzeAudio() {
    // Simulación de detección de tono
    final pitch = _simulatePitchDetection();
    if (pitch > 0) {
      setState(() => _currentPitch = pitch);
      _checkPitch(pitch, _expectedPitch);
    }
  }

  double _simulatePitchDetection() {
    // Simula la detección de tono (reemplaza con un algoritmo real)
    return 440.0; // Devuelve un tono fijo para pruebas
  }

  void _checkPitch(double detectedPitch, double expectedPitch) {
    const tolerance = 10.0; // Tolerancia para la afinación
    final difference = (detectedPitch - expectedPitch).abs();
    if (difference < tolerance) {
      print('¡Estás afinado! - Diferencia: $difference Hz **** Tolerancia: $tolerance');
    } else {
      print('¡Estás desafinado! - Diferencia: $difference Hz **** Tolerancia: $tolerance');
    }
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder(); // Cierra el grabador
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Karaoke App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pitch detectado: ${_currentPitch.toStringAsFixed(2)} Hz',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Detener grabación' : 'Comenzar grabación'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _audioPlayer.play(),
              child: Text('Reproducir música'),
            ),
          ],
        ),
      ),
    );
  }
}*/