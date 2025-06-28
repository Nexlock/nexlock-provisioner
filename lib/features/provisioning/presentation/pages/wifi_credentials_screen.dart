import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/wifi_credentials.dart';
import '../providers/provisioning_provider.dart';

class WiFiCredentialsScreen extends ConsumerStatefulWidget {
  const WiFiCredentialsScreen({super.key});

  @override
  ConsumerState<WiFiCredentialsScreen> createState() =>
      _WiFiCredentialsScreenState();
}

class _WiFiCredentialsScreenState extends ConsumerState<WiFiCredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverIPController = TextEditingController(text: '192.168.1.100');
  final _serverPortController = TextEditingController(text: '3000');
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _serverIPController.dispose();
    _serverPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provisioningState = ref.watch(wifiProvisioningProvider);
    final selectedModule = provisioningState.selectedModule;

    // Listen to provisioning status changes
    ref.listen<WiFiProvisioningState>(wifiProvisioningProvider, (
      previous,
      current,
    ) {
      if (current.status == ProvisioningStatus.success) {
        context.go('/provisioning-status');
      } else if (current.status == ProvisioningStatus.error &&
          current.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(current.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Credentials'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.wifi,
                        size: 48,
                        color: Color(0xFF1E88E5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connected to: ${selectedModule?.name ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MAC: ${selectedModule?.macAddress ?? 'Unknown'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _ssidController,
                decoration: const InputDecoration(
                  labelText: 'WiFi Network (SSID)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wifi),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter WiFi network name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'WiFi Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter WiFi password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serverIPController,
                decoration: const InputDecoration(
                  labelText: 'Server IP Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cloud),
                  hintText: '192.168.1.100',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter server IP address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _serverPortController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Server Port',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.settings_ethernet),
                  hintText: '3000',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter server port';
                  }
                  final port = int.tryParse(value!);
                  if (port == null || port < 1 || port > 65535) {
                    return 'Please enter a valid port number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed:
                    provisioningState.status == ProvisioningStatus.provisioning
                        ? null
                        : _provisionWiFi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    provisioningState.status == ProvisioningStatus.provisioning
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Provisioning WiFi...'),
                          ],
                        )
                        : const Text(
                          'Configure WiFi',
                          style: TextStyle(fontSize: 18),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _provisionWiFi() async {
    if (!_formKey.currentState!.validate()) return;

    final credentials = WiFiCredentials(
      ssid: _ssidController.text.trim(),
      password: _passwordController.text,
      serverIP: _serverIPController.text.trim(),
      serverPort: int.tryParse(_serverPortController.text) ?? 3000,
    );

    await ref
        .read(wifiProvisioningProvider.notifier)
        .provisionWiFi(credentials);
  }
}
