import '../entities/nexlock_module.dart';
import '../entities/wifi_credentials.dart';

abstract class ProvisioningRepository {
  Stream<List<NexLockModule>> scanForModules();
  Future<bool> connectToModule(NexLockModule module);
  Future<bool> provisionWiFi(WiFiCredentials credentials);
  Future<void> disconnect();
  Future<bool> checkPermissions();
  Future<void> requestPermissions();
}
