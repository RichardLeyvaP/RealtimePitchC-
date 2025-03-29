import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:singing_app/core/bloc/pitch_cubit.dart';
import 'package:singing_app/core/models/audioPitch.model.dart';
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
 Future<void> _initAudio() async {
    try {
      await _audioRecorder.openRecorder(); // Abre el grabador
      print("Grabador abierto correctamente");
    } catch (e) {
      print("Error al abrir el grabador: $e");
    } 
  }

  Future<void> _startRecording() async {
    try {
      // Asegúrate de que el grabador está abierto
      await _audioRecorder.openRecorder();

      // Obtener directorio temporal para guardar el archivo
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/audio.wav';

      await _audioRecorder.startRecorder(
        toFile: filePath, // Ruta del archivo en la carpeta temporal
        codec: Codec.pcm16WAV,
      );
      setState(() => _isRecording = true);

      // Escucha los datos de audio en tiempo real
      _audioRecorder.onProgress!.listen((RecordingDisposition disposition) {
        // Aquí puedes procesar los datos de audio
       
      });
    } catch (e) {
      print("Error al iniciar la grabación: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      setState(() => _isRecording = false);
    } catch (e) {
      print("Error al detener la grabación: $e");
    }
  }

    @override
  void initState() {
    super.initState();
     requestPermissions().then((_) => _initAudio());
  }

 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio'),
      actions: [
        IconButton(
          icon:    Icon(_isRecording ? Icons.record_voice_over: Icons.record_voice_over_outlined,color:_isRecording? Colors.red:Colors.black,)    ,
           onPressed: () {
          _isRecording ? _stopRecording() :  _startRecording();
             },)
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
             List<AudioPitch> newPitches =     await libraryNativaService.loadLibrary(audioFiles[index]);                  
                // Enviar los nuevos datos al Cubit
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
)
,
          ),
        
        ],
      ),
    );
  }
}
