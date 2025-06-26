import 'dart:async';
import 'package:esp_provisioning_wifi/esp_provisioning_bloc.dart';
import 'package:esp_provisioning_wifi/esp_provisioning_event.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/nexlock_module.dart';
import '../../domain/entities/wifi_credentials.dart';

class EspProvisioningDataSource {
  late EspProvisioningBloc _espProvisioningBloc;
  StreamSubscription? _stateSubscription;
  StreamController<List<NexLockModule>>? _modulesController;
  StreamController<bool>? _connectionController;
  StreamController<bool>? _provisioningController;

  EspProvisioningDataSource() {
    _espProvisioningBloc = EspProvisioningBloc();
  }

  Future<bool> checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final bluetoothStatus = await Permission.bluetooth.status;
    final bluetoothScanStatus = await Permission.bluetoothScan.status;
    final bluetoothConnectStatus = await Permission.bluetoothConnect.status;

    return locationStatus.isGranted &&
        bluetoothStatus.isGranted &&
        bluetoothScanStatus.isGranted &&
        bluetoothConnectStatus.isGranted;
  }

  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  Stream<List<NexLockModule>> scanForModules() {
    _modulesController = StreamController<List<NexLockModule>>();

    _stateSubscription = _espProvisioningBloc.stream.listen((state) {
      final nexlockModules =
          state.bluetoothDevices
              .where((device) => device.startsWith('NexLock_'))
              .map(
                (device) => NexLockModule(
                  name: device,
                  deviceName: device,
                  macAddress: device.replaceFirst('NexLock_', ''),
                  rssi: -60, // Default RSSI since BLoC doesn't provide it
                ),
              )
              .toList();

      _modulesController?.add(nexlockModules);
    });

    // Start scanning with NexLock prefix
    _espProvisioningBloc.add(EspProvisioningEventStart('NexLock_'));

    return _modulesController!.stream;
  }

  Future<bool> connectToModule(NexLockModule module) async {
    final completer = Completer<bool>();
    StreamSubscription? subscription;

    subscription = _espProvisioningBloc.stream.listen((state) {
      if (state.wifiNetworks.isNotEmpty) {
        // Successfully connected and scanned WiFi networks
        subscription?.cancel();
        completer.complete(true);
      } else if (state.bluetoothDevice == module.deviceName &&
          state.bluetoothDevices.isEmpty) {
        // Connection failed
        subscription?.cancel();
        completer.complete(false);
      }
    });

    // Connect to the selected module with default proof of possession
    _espProvisioningBloc.add(
      EspProvisioningEventBleSelected(module.deviceName, 'abcd1234'),
    );

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        subscription?.cancel();
        return false;
      },
    );
  }

  Future<bool> provisionWiFi(WiFiCredentials credentials) async {
    final completer = Completer<bool>();
    StreamSubscription? subscription;

    subscription = _espProvisioningBloc.stream.listen((state) {
      // Check if provisioning was successful
      // The BLoC doesn't provide explicit success/failure events,
      // so we'll assume success if the process completes without errors
      if (state.bluetoothDevice.isNotEmpty && state.wifiNetworks.isNotEmpty) {
        subscription?.cancel();
        completer.complete(true);
      }
    });

    // Start WiFi provisioning
    _espProvisioningBloc.add(
      EspProvisioningEventWifiSelected(
        _espProvisioningBloc.state.bluetoothDevice,
        'abcd1234', // Default proof of possession
        credentials.ssid,
        credentials.password,
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        subscription?.cancel();
        return false;
      },
    );
  }

  Future<void> disconnect() async {
    await _stateSubscription?.cancel();
    _stateSubscription = null;
    await _modulesController?.close();
    _modulesController = null;
    await _connectionController?.close();
    _connectionController = null;
    await _provisioningController?.close();
    _provisioningController = null;
  }

  void dispose() {
    disconnect();
    _espProvisioningBloc.close();
  }
}
