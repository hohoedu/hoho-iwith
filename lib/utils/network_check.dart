import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

////////////////////////////////
// 네트워크 연결 체크 컨트롤러 //
////////////////////////////////

class ConnectivityController extends GetxController {
  var isConnected = false.obs;
  final Connectivity connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    connectivity.onConnectivityChanged.listen(updateConnectionStatus);
    checkInitialConnection();
  }

  Future<void> checkInitialConnection() async {
    var connectivityResult = await connectivity.checkConnectivity();
    updateConnectionStatus(connectivityResult);
  }

  void updateConnectionStatus(ConnectivityResult result) {
    // 와이파이나 데이터에 연결된 경우
    if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
      isConnected.value = true;
    } else {
      isConnected.value = false;
    }
  }
}