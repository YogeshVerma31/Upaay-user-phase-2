import 'dart:io';

class NetworkCheckUp {
  Future<bool> checkConnection() async {
    bool status = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        status = true;
      }
      return status;
    } on SocketException catch (_) {
      return status;
    }
  }
}
