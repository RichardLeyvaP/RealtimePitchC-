import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:singing_app/core/bloc/pitch_cubit.dart';
import 'package:singing_app/core/models/audioPitch.model.dart';
import 'package:singing_app/core/services/audioSegment.service.dart';
import 'package:singing_app/core/services/requestPermissions.service.dart';
import 'package:singing_app/services/libraryNativa.service.dart';

class ConvertAudioPage extends StatefulWidget {
  @override
  _ConvertAudioPageState createState() => _ConvertAudioPageState();
}

class _ConvertAudioPageState extends State<ConvertAudioPage> {
  final List<String> audioFiles = [
    'assets/vocals/sample-3s.wav',
    'assets/vocals/sample-15s.wav',
    'assets/vocals/sample-12s.wav',
  ];

  LibraryNativaService libraryNativaService = LibraryNativaService();
  String? convertedFilePath;
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  late ContinuousAudioProcessor _audioProcessor;

  @override
  void initState() {
    super.initState();
    _audioProcessor = ContinuousAudioProcessor(_handleAudioSegment);
    requestPermissions().then((_) => _initAudio());
  }

  Future<void> _initAudio() async {
    try {
      await _audioRecorder.openRecorder();
      print("Grabador abierto correctamente");
    } catch (e) {
      print("Error al abrir el grabador: $e");
    }
  }

 Future<void> _handleAudioSegment(String segmentPath) async {
  try {
    // Verifica si el archivo existe y tiene contenido
    print( "Segmento recibido: $segmentPath \n ");
    final file = File(segmentPath);
    if (await file.exists() && await file.length() > 0) {
      // Usa el path directo en lugar de tratarlo como asset
      List<AudioPitch> newPitches = await libraryNativaService.loadLibraryAssets(segmentPath);
      
      // Enviar los nuevos datos al Cubit
      if (mounted) {
        context.read<PitchCubit>().addPitches(newPitches);
      }
      
      // Opcional: Eliminar el archivo temporal después de procesar
      await file.delete();
    } else {
      print("Archivo de segmento no válido o vacío: $segmentPath");
    }
  } catch (e) {
    print("Error procesando segmento: $e");
    if (e.toString().contains("Unable to load asset")) {
      print("SOLUCIÓN: Asegúrate que tu método loadLibrary() acepte paths de archivos reales, no solo assets");
    }
  }
}

  Future<void> _startRecording() async {
    try {
      await _audioRecorder.openRecorder();
      setState(() => _isRecording = true);
      await _audioProcessor.startRecording();
    } catch (e) {
      print("Error al iniciar la grabación: $e");
      setState(() => _isRecording = false);
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioProcessor.stopRecording();
      await _audioRecorder.stopRecorder();
      setState(() => _isRecording = false);
    } catch (e) {
      print("Error al detener la grabación: $e");
    }
  }

  @override
  void dispose() {
    _audioProcessor.stopRecording();
    _audioRecorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio'),
        actions: [
          IconButton(
            icon: Icon(
              _isRecording ? Icons.record_voice_over : Icons.record_voice_over_outlined,
              color: _isRecording ? Colors.red : Colors.black,
            ),
            onPressed: () {
              _isRecording ? _stopRecording() : _startRecording();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: audioFiles.length,
              itemBuilder: (context, index) {
                String fileName = audioFiles[index].split('/').last;
                return ListTile(
                  title: Text(fileName),
                  trailing: Icon(Icons.audiotrack),
                  onTap: () async {
                    List<AudioPitch> newPitches = await libraryNativaService.loadLibrary(audioFiles[index]);
                    context.read<PitchCubit>().addPitches(newPitches);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<PitchCubit, List<AudioPitch>>(
              builder: (context, pitches) {
                return ListView.builder(
                  itemCount: pitches.length,
                  itemBuilder: (context, index) {
                    final pitch = pitches[index];
                    return ListTile(
                      title: Text("Note: ${pitch.note}"),
                      subtitle: Text(
                        "Pitch: ${pitch.pitch.toStringAsFixed(2)} Hz - Duration: ${pitch.duration.toStringAsFixed(4)} sec",
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:flutter_sound/public/flutter_sound_recorder.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:singing_app/core/bloc/pitch_cubit.dart';
// import 'package:singing_app/core/models/audioPitch.model.dart';
// import 'package:singing_app/core/services/requestPermissions.service.dart';
// import 'package:singing_app/services/libraryNativa.service.dart';

// class ConvertAudioPage extends StatefulWidget {
//   @override
//   _ConvertAudioPageState createState() => _ConvertAudioPageState();
// }


// class _ConvertAudioPageState extends State<ConvertAudioPage> {


//   final List<String> audioFiles = [
//     'assets/vocals/sample-3s.wav',
//     'assets/vocals/sample-15s.wav',
//     'assets/vocals/sample-12s.wav',
    
//   ];
// LibraryNativaService libraryNativaService = LibraryNativaService();
//   String? convertedFilePath;
//   final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
//    bool _isRecording = false;
//  Future<void> _initAudio() async {
//     try {
//       await _audioRecorder.openRecorder(); // Abre el grabador
//       print("Grabador abierto correctamente");
//     } catch (e) {
//       print("Error al abrir el grabador: $e");
//     } 
//   }

//   Future<void> _startRecording() async {
//     try {
//       // Asegúrate de que el grabador está abierto
//       await _audioRecorder.openRecorder();

//       // Obtener directorio temporal para guardar el archivo
//       final directory = await getTemporaryDirectory();
//       final filePath = '${directory.path}/audio.wav';

//       await _audioRecorder.startRecorder(
//         toFile: filePath, // Ruta del archivo en la carpeta temporal
//         codec: Codec.pcm16WAV,
//       );
//       setState(() => _isRecording = true);

//       // Escucha los datos de audio en tiempo real
//       _audioRecorder.onProgress!.listen((RecordingDisposition disposition) {
//         // Aquí puedes procesar los datos de audio
       
//       });
//     } catch (e) {
//       print("Error al iniciar la grabación: $e");
//     }
//   }

//   Future<void> _stopRecording() async {
//     try {
//       await _audioRecorder.stopRecorder();
//       setState(() => _isRecording = false);
//     } catch (e) {
//       print("Error al detener la grabación: $e");
//     }
//   }

//     @override
//   void initState() {
//     super.initState();
//      requestPermissions().then((_) => _initAudio());
//   }

 
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Audio'),
//       actions: [
//         IconButton(
//           icon:    Icon(_isRecording ? Icons.record_voice_over: Icons.record_voice_over_outlined,color:_isRecording? Colors.red:Colors.black,)    ,
//            onPressed: () {
//           _isRecording ? _stopRecording() :  _startRecording();
//              },)
//       ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: audioFiles.length,
//               itemBuilder: (context, index) {
//                 String fileName = audioFiles[index].split('/').last;
//                 return ListTile(
//                   title: Text(fileName),
//                   trailing: Icon(Icons.audiotrack),
//                   onTap: () async {
//              List<AudioPitch> newPitches =     await libraryNativaService.loadLibrary(audioFiles[index]);                  
//                 // Enviar los nuevos datos al Cubit
//                 context.read<PitchCubit>().addPitches(newPitches);
//                   },
//                 );
//               },
//             ),
//           ),
//           Expanded(
//             child: BlocBuilder<PitchCubit, List<AudioPitch>>(
//   builder: (context, pitches) {
//     return ListView.builder(
//       itemCount: pitches.length,
//       itemBuilder: (context, index) {
//         final pitch = pitches[index];
//         return ListTile(
//           title: Text("Note: ${pitch.note}"),
//           subtitle: Text(
//             "Pitch: ${pitch.pitch.toStringAsFixed(2)} Hz - Duration: ${pitch.duration.toStringAsFixed(4)} sec",
//           ),
//         );
//       },
//     );
//   },
// )
// ,
//           ),
        
//         ],
//       ),
//     );
//   }
// }
