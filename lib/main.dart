import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:singing_app/core/dependencies/dependencies.dart';
import 'package:singing_app/core/services/requestPermissions.service.dart';
import 'package:singing_app/native/native_bindings.dart';
import 'package:singing_app/singing_app.dart';
import 'package:singing_app/ui/homeScreen.dart';



import 'package:flutter/material.dart';




import 'dart:ffi'; // Para FFI
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

typedef AnalyzeWavFunc = Void Function(Pointer<Utf8>);
typedef AnalyzeWav = void Function(Pointer<Utf8>);

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para usar path_provider
  String tempFilePath = await copyAssetToTemp('assets/vocals/HEALTH_CHECK.wav');
  
  final dylib = DynamicLibrary.open('libnative-lib.so'); // Nombre de la biblioteca C++
  final analyzeWav = dylib.lookupFunction<AnalyzeWavFunc, AnalyzeWav>('analyzeWav');

  analyzeWav(tempFilePath.toNativeUtf8()); // Llamar a la función C++

  runApp(MyApp());
}

Future<String> copyAssetToTemp(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  final Directory tempDir = await getTemporaryDirectory();
  final File tempFile = File('${tempDir.path}/HEALTH_CHECK.wav');
  await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
  return tempFile.path;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Flutter + C++")),
        body: Center(
          child: Text("Archivo de audio procesado"), // Mensaje de confirmación
        ),
      ),
    );
  }
}































// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: Text("Flutter + C++")),
//         body: Center(
//           child: Text('stringFromCpp().toDartString()'), // Mostrar mensaje C++
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