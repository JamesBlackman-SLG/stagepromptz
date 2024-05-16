import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermissions() async {
  final status = await Permission.storage.request();
  if (status == PermissionStatus.granted) {
    return true;
  } else {
    return false;
  }
}
