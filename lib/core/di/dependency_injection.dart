import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/provisioning/data/datasources/esp_provisioning_datasource.dart';
import '../../features/provisioning/data/repositories/provisioning_repository_impl.dart';
import '../../features/provisioning/domain/repositories/provisioning_repository.dart';
import '../../features/provisioning/domain/usecases/scan_for_modules.dart';
import '../../features/provisioning/domain/usecases/connect_to_module.dart';
import '../../features/provisioning/domain/usecases/provision_wifi.dart';

// Data Source Provider
final espProvisioningDataSourceProvider = Provider<EspProvisioningDataSource>((
  ref,
) {
  return EspProvisioningDataSource();
});

// Repository Provider
final provisioningRepositoryProvider = Provider<ProvisioningRepository>((ref) {
  final dataSource = ref.watch(espProvisioningDataSourceProvider);
  return ProvisioningRepositoryImpl(dataSource);
});

// Use Case Providers
final scanForModulesUseCaseProvider = Provider<ScanForModules>((ref) {
  final repository = ref.watch(provisioningRepositoryProvider);
  return ScanForModules(repository);
});

final connectToModuleUseCaseProvider = Provider<ConnectToModule>((ref) {
  final repository = ref.watch(provisioningRepositoryProvider);
  return ConnectToModule(repository);
});

final provisionWiFiUseCaseProvider = Provider<ProvisionWiFi>((ref) {
  final repository = ref.watch(provisioningRepositoryProvider);
  return ProvisionWiFi(repository);
});
