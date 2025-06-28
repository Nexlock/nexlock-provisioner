abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class DeviceConnectionFailure extends Failure {
  const DeviceConnectionFailure(super.message);
}

class ProvisioningFailure extends Failure {
  const ProvisioningFailure(super.message);
}

class ScanningFailure extends Failure {
  const ScanningFailure(super.message);
}
