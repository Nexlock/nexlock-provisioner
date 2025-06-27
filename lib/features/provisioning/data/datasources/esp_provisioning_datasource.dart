import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/nexlock_module.dart';
import '../../domain/entities/wifi_credentials.dart';

class EspProvisioningDataSource {
  StreamController<List<NexLockModule>>? _modulesController;
  Timer? _scanTimer;

  Future<bool> checkPermissions() async {
    final locationStatus = await Permission.location.status;
    return locationStatus.isGranted;
  }

  Future<void> requestPermissions() async {
    await [Permission.location].request();
  }

  Stream<List<NexLockModule>> scanForModules() {
    _modulesController = StreamController<List<NexLockModule>>();

    _scanTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final canStartScan = await WiFiScan.instance.canStartScan();
        if (canStartScan == CanStartScan.yes) {
          await WiFiScan.instance.startScan();
          await Future.delayed(const Duration(seconds: 3));
          final accessPoints = await WiFiScan.instance.getScannedResults();

          final nexlockModules =
              accessPoints
                  .where((ap) => ap.ssid.startsWith('NexLock_'))
                  .map(
                    (ap) => NexLockModule(
                      name: ap.ssid,
                      deviceName: ap.ssid,
                      macAddress: ap.ssid.replaceFirst('NexLock_', ''),
                      rssi: ap.level,
                    ),
                  )
                  .toList();

          _modulesController?.add(nexlockModules);
        }
      } catch (e) {
        print('Error scanning for WiFi: $e');
      }
    });

    return _modulesController!.stream;
  }

  Future<bool> connectToModule(NexLockModule module) async {
    try {
      // Connect to the NexLock WiFi AP
      // Note: This requires platform-specific implementation
      // You may need to use wifi_flutter package or similar
      return true; // Placeholder - actual WiFi connection implementation needed
    } catch (e) {
      print('Error connecting to module: $e');
      return false;
    }
  }

  Future<bool> provisionWiFi(WiFiCredentials credentials) async {
    try {
      final response = await http
          .post(
            Uri.parse('http://192.168.4.1/configure'),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'ssid': credentials.ssid,
              'password': credentials.password,
              'serverIP': credentials.serverIP,
              'serverPort': credentials.serverPort.toString(),
            },
          )
          .timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (e) {
      print('Error provisioning WiFi: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    _scanTimer?.cancel();
    await _modulesController?.close();
    _modulesController = null;
  }

  void dispose() {
    disconnect();
  }
}
