class WiFiCredentials {
  final String ssid;
  final String password;
  final String serverIP;
  final int serverPort;

  const WiFiCredentials({
    required this.ssid,
    required this.password,
    required this.serverIP,
    this.serverPort = 3000,
  });

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'password': password,
      'serverIP': serverIP,
      'serverPort': serverPort,
    };
  }

  @override
  String toString() {
    return 'WiFiCredentials(ssid: $ssid, serverIP: $serverIP, serverPort: $serverPort)';
  }
}
