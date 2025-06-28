import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlock_provisioner/core/di/dependency_injection.dart';
import '../providers/provisioning_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NexLock Provisioner'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 100, height: 100),
              const SizedBox(height: 32),
              const Text(
                'Welcome to NexLock Provisioner',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Configure your NexLock modules with WiFi credentials to connect them to your network.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _handlePermissionsAndNavigate(context, ref);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Find NexLock Modules',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePermissionsAndNavigate(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final repository = ref.read(provisioningRepositoryProvider);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Checking permissions...'),
              ],
            ),
          ),
    );

    try {
      // Check permissions first
      final hasPermissions = await repository.checkPermissions();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (!hasPermissions) {
        // Show permission explanation dialog
        final shouldRequest = await _showPermissionExplanationDialog(context);

        if (!shouldRequest) return;

        // Show requesting permissions dialog
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Requesting permissions...'),
                      SizedBox(height: 8),
                      Text(
                        'Please allow location and nearby devices permissions in the system dialog.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
          );
        }

        await repository.requestPermissions();

        if (context.mounted) {
          Navigator.of(context).pop(); // Close requesting dialog
        }

        // Verify permissions were granted
        final permissionsGranted = await repository.checkPermissions();

        if (!permissionsGranted && context.mounted) {
          await _showPermissionDeniedDialog(context);
          return;
        }
      }

      // Reset provisioning state and navigate
      ref.read(wifiProvisioningProvider.notifier).reset();

      if (context.mounted) {
        context.go('/scan');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close any open dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking permissions: $e')),
        );
      }
    }
  }

  Future<bool> _showPermissionExplanationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Permissions Required'),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('To find NexLock modules, this app needs:'),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Location access\n(Required for WiFi scanning on all Android versions)',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.wifi, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nearby WiFi devices\n(Required on Android 13 and newer)',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'These permissions are only used to scan for WiFi networks created by NexLock modules in provisioning mode.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Grant Permissions'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permissions Required'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, size: 48, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'Location permission is required to scan for WiFi networks.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'To enable permissions manually:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Go to Settings > Apps > NexLock Provisioner\n'
                  '2. Tap Permissions\n'
                  '3. Enable Location\n'
                  '4. On Android 13+, also enable Nearby devices',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // You can use open_settings package here if needed
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }
}
