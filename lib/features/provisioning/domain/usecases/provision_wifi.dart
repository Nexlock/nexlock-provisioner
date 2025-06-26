import '../entities/wifi_credentials.dart';
import '../repositories/provisioning_repository.dart';

class ProvisionWiFi {
  final ProvisioningRepository repository;

  ProvisionWiFi(this.repository);

  Future<bool> call(WiFiCredentials credentials) {
    return repository.provisionWiFi(credentials);
  }
}
