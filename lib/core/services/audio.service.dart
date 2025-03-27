import 'package:path_provider/path_provider.dart';

class AudioService {

  Future<String> getAudioPath() async {
  // Obtener el directorio temporal del dispositivo
  final directory = await getTemporaryDirectory();

  // Crear un nombre de archivo único
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final fileName = 'audio_$timestamp.wav';

  // Combinar el directorio y el nombre del archivo
  return '${directory.path}/$fileName';
}

  
}