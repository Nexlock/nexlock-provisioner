class NexLockModule {
  final String name;
  final String deviceName;
  final String macAddress;
  final int rssi;
  final bool isConnected;
  final String? ipAddress;

  const NexLockModule({
    required this.name,
    required this.deviceName,
    required this.macAddress,
    required this.rssi,
    this.isConnected = false,
    this.ipAddress,
  });

  NexLockModule copyWith({
    String? name,
    String? deviceName,
    String? macAddress,
    int? rssi,
    bool? isConnected,
    String? ipAddress,
  }) {
    return NexLockModule(
      name: name ?? this.name,
      deviceName: deviceName ?? this.deviceName,
      macAddress: macAddress ?? this.macAddress,
      rssi: rssi ?? this.rssi,
      isConnected: isConnected ?? this.isConnected,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }

  @override
  String toString() {
    return 'NexLockModule(name: $name, macAddress: $macAddress, rssi: $rssi, isConnected: $isConnected)';
  }
}
