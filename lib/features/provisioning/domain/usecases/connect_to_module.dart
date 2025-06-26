import '../entities/nexlock_module.dart';
import '../repositories/provisioning_repository.dart';

class ConnectToModule {
  final ProvisioningRepository repository;

  ConnectToModule(this.repository);

  Future<bool> call(NexLockModule module) {
    return repository.connectToModule(module);
  }
}
