import '../../domain/entities/nexlock_module.dart';
import '../../domain/entities/wifi_credentials.dart';
import '../../domain/repositories/provisioning_repository.dart';
import '../datasources/esp_provisioning_datasource.dart';

class ProvisioningRepositoryImpl implements ProvisioningRepository {
  final EspProvisioningDataSource dataSource;

  ProvisioningRepositoryImpl(this.dataSource);

  @override
  Stream<List<NexLockModule>> scanForModules() {
    return dataSource.scanForModules();
  }

  @override
  Future<bool> connectToModule(NexLockModule module) {
    return dataSource.connectToModule(module);
  }

  @override
  Future<bool> provisionWiFi(WiFiCredentials credentials) {
    return dataSource.provisionWiFi(credentials);
  }

  @override
  Future<void> disconnect() {
    return dataSource.disconnect();
  }

  @override
  Future<bool> checkPermissions() {
    return dataSource.checkPermissions();
  }

  @override
  Future<void> requestPermissions() {
    return dataSource.requestPermissions();
  }
}
