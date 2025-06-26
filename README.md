# 📱 NexLock Provisioner - ESP32 Module Setup App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/ESP32-000000?style=for-the-badge&logo=Espressif&logoColor=white" />
  <img src="https://img.shields.io/badge/WiFi-Provisioning-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Bluetooth-Enabled-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge" />
</div>

## 🚀 What is NexLock Provisioner?

NexLock Provisioner is a **Flutter mobile application** designed to seamlessly configure and provision ESP32-based NexLock smart locker modules. This app provides an intuitive interface for setting up WiFi credentials, server connections, and device configurations for your NexLock ecosystem.

### ✨ Key Features

- 📡 **ESP32 WiFi Provisioning** - Configure WiFi credentials wirelessly
- 🔗 **Bluetooth Discovery** - Find and connect to NexLock modules
- 🛠️ **Device Configuration** - Set server endpoints and module settings
- 📋 **Network Scanning** - Display available WiFi networks
- 🔧 **Bulk Provisioning** - Configure multiple modules efficiently
- 📱 **Cross-Platform** - Works on Android and iOS
- 🎯 **User-Friendly** - Simple, intuitive interface
- 🔄 **Real-time Feedback** - Live provisioning status updates

## 🛠️ Hardware Requirements

### Compatible Devices

- **ESP32 Development Boards** with WiFi capability
- **NexLock Smart Locker Modules** (ESP32-based)
- **Android 6.0+** or **iOS 12.0+** mobile device
- **Bluetooth 4.0+** support on mobile device

## 🚀 Quick Start Guide

### 1. 📥 Installation

#### From Source

```bash
# Clone the repository
git clone https://github.com/your-username/nexlock_provisioner.git
cd nexlock_provisioner

# Install dependencies
flutter pub get

# Run the app
flutter run
```

#### Dependencies

The app uses these key packages:

```yaml
dependencies:
  esp_provisioning_wifi: ^0.0.6 # ESP32 WiFi provisioning
  permission_handler: ^11.3.1 # Runtime permissions
  cupertino_icons: ^1.0.8 # iOS-style icons
```

### 2. 🔧 Permissions Setup

The app requires these permissions for proper operation:

**Android:**

- WiFi state access and modification
- Bluetooth scanning and connection
- Location access (required for WiFi scanning)
- Network state monitoring

**iOS:**

- Location access for WiFi scanning
- Bluetooth usage for device discovery

### 3. ⚡ First Use

1. **Launch the app** on your mobile device
2. **Grant permissions** when prompted (Location, Bluetooth, WiFi)
3. **Scan for devices** - Find nearby NexLock modules in provisioning mode
4. **Select module** to configure
5. **Choose WiFi network** from scanned list
6. **Enter credentials** and server details
7. **Provision device** - Watch real-time progress!

## 📁 Project Structure

```
nexlock_provisioner/
├── 📁 lib/
│   ├── 📄 main.dart                # App entry point
│   ├── 📁 screens/
│   │   ├── 📄 home_screen.dart     # Main app interface
│   │   ├── 📄 scan_screen.dart     # Device discovery
│   │   └── 📄 provision_screen.dart # WiFi setup
│   ├── 📁 services/
│   │   ├── 📄 provisioning_service.dart # ESP32 communication
│   │   └── 📄 bluetooth_service.dart    # Device discovery
│   └── 📁 widgets/
│       ├── 📄 device_card.dart     # Device list items
│       └── 📄 wifi_list.dart       # Network selection
├── 📁 android/                     # Android-specific files
├── 📁 ios/                        # iOS-specific files
├── 📄 pubspec.yaml                # Dependencies & metadata
└── 📄 README.md                   # You are here! 👋
```

## 🎮 Usage

### Device Discovery

1. **Enable Bluetooth** on your mobile device
2. **Open NexLock Provisioner**
3. **Tap "Scan for Devices"**
4. **Select your NexLock module** from the list

### WiFi Provisioning

1. **Choose WiFi network** from scanned list
2. **Enter network password**
3. **Configure server settings**:
   - Server IP address
   - Port number (default: 3000)
   - Module identifier
4. **Start provisioning** - Monitor progress in real-time

### Bulk Configuration

1. **Select multiple devices** from discovery list
2. **Apply same WiFi settings** to all selected modules
3. **Monitor individual progress** for each device
4. **Verify successful configuration**

## 🔌 ESP32 Integration

### Supported Provisioning Methods

- **BLE (Bluetooth Low Energy)** - Primary method
- **SoftAP** - Fallback WiFi hotspot method
- **SmartConfig** - Broadcast-based provisioning

### Configuration Data

The app sends these parameters to ESP32 modules:

```json
{
  "ssid": "YourWiFiNetwork",
  "password": "YourWiFiPassword",
  "server_ip": "192.168.1.100",
  "server_port": 3000,
  "module_id": "nexlock_001",
  "encryption_key": "optional_security_key"
}
```

## 🔧 Configuration

### App Settings

Customize app behavior through configuration:

```dart
// lib/config/app_config.dart
class AppConfig {
  static const String defaultServerPort = "3000";
  static const int scanTimeout = 30; // seconds
  static const int provisionTimeout = 120; // seconds
  static const bool enableDebugLogs = true;
}
```

### Server Integration

Configure your NexLock server endpoints:

- **Default Port**: 3000
- **Protocol**: WebSocket with Socket.IO
- **Authentication**: Module-based registration

## 🐛 Troubleshooting

### Common Issues

**🔴 Bluetooth Not Working**

- Enable Bluetooth on your device
- Grant location permissions (Android requirement)
- Restart the app after enabling permissions

**🔴 WiFi Networks Not Showing**

- Grant location permissions
- Ensure you're near WiFi networks
- Try refreshing the network list

**🔴 Provisioning Failed**

- Check WiFi password accuracy
- Verify server IP and port
- Ensure ESP32 is in provisioning mode
- Check network connectivity

**🔴 Device Not Found**

- Put ESP32 in provisioning mode
- Check Bluetooth is enabled
- Move closer to the device
- Restart device scanning

### Debug Mode

Enable verbose logging in development:

```dart
// Add to main.dart
void main() {
  if (kDebugMode) {
    Logger.root.level = Level.ALL;
  }
  runApp(MyApp());
}
```

## 🔒 Security

### Data Protection

- **Local Storage**: Sensitive data encrypted
- **Network Communication**: TLS/SSL when available
- **Credential Handling**: Temporary storage only
- **Permission Model**: Minimal required permissions

### Best Practices

- Clear provisioning data after successful setup
- Use strong WiFi passwords
- Secure your NexLock server endpoints
- Regular app updates for security patches

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. 🍴 **Fork** the repository
2. 🌿 **Create** a feature branch (`git checkout -b feature/awesome-feature`)
3. 💾 **Commit** your changes (`git commit -m 'Add awesome feature'`)
4. 📤 **Push** to the branch (`git push origin feature/awesome-feature`)
5. 🎯 **Open** a Pull Request

### Development Guidelines

- Follow Flutter/Dart style guidelines
- Add unit tests for new features
- Update documentation
- Test on both Android and iOS
- Ensure backward compatibility

## 📱 Platform Support

### Android Requirements

- **Minimum SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Permissions**: Location, Bluetooth, WiFi

### iOS Requirements

- **Minimum Version**: iOS 12.0
- **Target Version**: iOS 17.0
- **Permissions**: Location, Bluetooth

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🏆 Credits

Created with ❤️ by the NexLock team

### Special Thanks

- **ESP32 Community** - Amazing hardware platform
- **Flutter Team** - Excellent mobile framework
- **esp_provisioning_wifi** - ESP32 integration package
- **Open Source Contributors** - Making this possible

## 📞 Support

Need help? We've got you covered!

- 📧 **Email**: support@nexlock.com
- 💬 **Discord**: [Join our community](https://discord.gg/nexlock)
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-username/nexlock_provisioner/issues)
- 📖 **Documentation**: [Full Docs](https://docs.nexlock.com)

## 🔗 Related Projects

- **[NexLock ESP32 Firmware](https://github.com/your-username/nexlock-ino)** - Smart locker module firmware
- **[NexLock Server](https://github.com/your-username/nexlock-server)** - Backend management system
- **[NexLock Admin](https://github.com/your-username/nexlock-admin)** - Web administration panel

---

<div align="center">
  <h3>🌟 Star this repository if you found it helpful! 🌟</h3>
  <p>Made with 💖 and lots of ☕</p>
  <p><strong>Simplifying ESP32 provisioning, one tap at a time! 📱✨</strong></p>
</div>
