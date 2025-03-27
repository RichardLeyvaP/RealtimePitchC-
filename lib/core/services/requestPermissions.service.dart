import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }

   final statusPhone = await Permission.microphone.request();
  if (!statusPhone.isGranted) {
    throw Exception('Permiso de micrófono no concedido');
  } 
}

