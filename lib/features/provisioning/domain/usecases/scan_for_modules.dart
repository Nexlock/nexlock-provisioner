import '../entities/nexlock_module.dart';
import '../repositories/provisioning_repository.dart';

class ScanForModules {
  final ProvisioningRepository repository;

  ScanForModules(this.repository);

  Stream<List<NexLockModule>> call() {
    return repository.scanForModules();
  }
}
