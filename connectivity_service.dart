import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Stream<bool> get onConnectivityChanged {
    return Connectivity().onConnectivityChanged.map(
          (result) => !result.contains(ConnectivityResult.none),
        );
  }
}
