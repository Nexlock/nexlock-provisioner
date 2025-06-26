import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/esp_provisioning_datasource.dart';
import '../../data/repositories/provisioning_repository_impl.dart';
import '../../domain/entities/nexlock_module.dart';
import '../../domain/usecases/connect_to_module.dart';
import '../../domain/usecases/provision_wifi.dart';
import '../../domain/usecases/scan_for_modules.dart';

// Data Source Provider
final espProvisioningDataSourceProvider = Provider((ref) {
  return EspProvisioningDataSource();
});

// Repository Provider
final provisioningRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(espProvisioningDataSourceProvider);
  return ProvisioningRepositoryImpl(dataSource);
});

// Use Cases
final scanForModulesProvider = Provider((ref) {
  final repository = ref.watch(provisioningRepositoryProvider);
  return ScanForModules(repository);
});

final connectToModuleProvider = Provider((ref) {
  final repository = ref.watch(provisioningRepositoryProvider);
  return ConnectToModule(repository);
});

final provisionWiFiProvider = Provider((ref) {
  final repository = ref.watch(provisioningRepositoryProvider);
  return ProvisionWiFi(repository);
});

// State Providers
final scannedModulesProvider = StreamProvider<List<NexLockModule>>((ref) {
  final scanUseCase = ref.watch(scanForModulesProvider);
  return scanUseCase().handleError((error) {
    // Handle BLoC errors gracefully
    print('Scanning error: $error');
    return <NexLockModule>[];
  });
});

final selectedModuleProvider = StateProvider<NexLockModule?>((ref) => null);

final isConnectedProvider = StateProvider<bool>((ref) => false);

final provisioningStatusProvider = StateProvider<ProvisioningStatus>(
  (ref) => ProvisioningStatus.idle,
);

enum ProvisioningStatus {
  idle,
  scanning,
  connecting,
  connected,
  provisioning,
  success,
  error,
}
