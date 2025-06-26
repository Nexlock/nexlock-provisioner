class WiFiCredentials {
  final String ssid;
  final String password;
  final String? serverIP;
  final int? serverPort;

  const WiFiCredentials({
    required this.ssid,
    required this.password,
    this.serverIP,
    this.serverPort,
  });

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'password': password,
      if (serverIP != null) 'serverIP': serverIP,
      if (serverPort != null) 'serverPort': serverPort,
    };
  }

  @override
  String toString() {
    return 'WiFiCredentials(ssid: $ssid, serverIP: $serverIP, serverPort: $serverPort)';
  }
}
