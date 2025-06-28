import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:nexlock_provisioner/core/di/dependency_injection.dart';
import 'package:nexlock_provisioner/features/provisioning/domain/entities/nexlock_module.dart';
import '../providers/provisioning_provider.dart';

class ModuleScannerWidget extends ConsumerWidget {
  const ModuleScannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(scannedModulesProvider);
    final provisioningState = ref.watch(wifiProvisioningProvider);

    return Column(
      children: [
        const Text(
          'Scanning for WiFi Networks...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'DEBUG MODE: Showing ALL WiFi networks to test scanning functionality',
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange[700],
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Looking for networks starting with "NexLock_", "ESP32_", or containing "nexlock"',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (provisioningState.status == ProvisioningStatus.scanning)
          const CircularProgressIndicator(),
        const SizedBox(height: 8),
        // Debug info with refresh button
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Text(
                'Status: ${provisioningState.status.name}\n'
                'Scan State: ${modulesAsync.when(data: (modules) => 'Found ${modules.length} modules', loading: () => 'Scanning...', error: (e, _) => 'Error: $e')}',
                style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  print('Manual refresh requested');
                  ref.invalidate(scannedModulesProvider);
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text(
                  'Refresh Now',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed: () => _testWiFiDirectly(context, ref),
                icon: const Icon(Icons.bug_report, size: 16),
                label: const Text(
                  'Test WiFi Directly',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: modulesAsync.when(
            data: (modules) {
              if (modules.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No NexLock modules found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Make sure the module is in provisioning mode.\n'
                        'The module should create a WiFi hotspot named "NexLock_XXXX".',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed:
                                () => ref.invalidate(scannedModulesProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Scan'),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _checkPermissions(context, ref),
                            icon: const Icon(Icons.security),
                            label: const Text('Check Permissions'),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const Text(
                            'Still not working?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _addManualModule(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Module Manually'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];

                  // Check if this is actually a NexLock module
                  final isActualNexLock =
                      module.name.startsWith('NexLock_') ||
                      module.name.toLowerCase().startsWith('nexlock') ||
                      module.name.startsWith('ESP32_') ||
                      module.name.toLowerCase().contains('nexlock');

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color:
                        isActualNexLock
                            ? Colors.green.shade50
                            : Colors.grey.shade50,
                    child: ListTile(
                      leading: Icon(
                        isActualNexLock ? Icons.lock : Icons.wifi,
                        color:
                            isActualNexLock
                                ? Colors.green
                                : _getSignalColor(module.rssi),
                      ),
                      title: Row(
                        children: [
                          if (isActualNexLock)
                            const Icon(
                              Icons.star,
                              color: Colors.green,
                              size: 16,
                            ),
                          Expanded(
                            child: Text(
                              module.name,
                              style: TextStyle(
                                fontWeight:
                                    isActualNexLock
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isActualNexLock
                                        ? Colors.green.shade800
                                        : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BSSID: ${module.macAddress}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Signal: ${module.rssi} dBm (${_getSignalStrength(module.rssi)})',
                            style: const TextStyle(fontSize: 11),
                          ),
                          if (isActualNexLock)
                            const Text(
                              '⭐ NEXLOCK MODULE - Tap to connect',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            const Text(
                              'Regular WiFi network (debug view)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      trailing:
                          provisioningState.status ==
                                  ProvisioningStatus.connecting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : isActualNexLock
                              ? const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.green,
                              )
                              : const Icon(
                                Icons.info_outline,
                                color: Colors.grey,
                              ),
                      onTap:
                          provisioningState.status ==
                                  ProvisioningStatus.connecting
                              ? null
                              : isActualNexLock
                              ? () => _connectToModule(context, ref, module)
                              : () => _showNetworkInfo(context, module),
                    ),
                  );
                },
              );
            },
            loading:
                () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Initializing WiFi scanning...'),
                      SizedBox(height: 8),
                      Text(
                        'This may take a moment while we check permissions and start scanning.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            error:
                (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'WiFi Scanning Error',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed:
                                () => ref.invalidate(scannedModulesProvider),
                            child: const Text('Try Again'),
                          ),
                          const SizedBox(height: 8),
                          if (error.toString().contains('permission'))
                            TextButton.icon(
                              onPressed: () => _checkPermissions(context, ref),
                              icon: const Icon(Icons.security),
                              label: const Text('Check Permissions'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ],
    );
  }

  Future<void> _connectToModule(
    BuildContext context,
    WidgetRef ref,
    NexLockModule module,
  ) async {
    // Show instructions for manual WiFi connection
    final shouldContinue =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Connect to Module'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('To configure ${module.name}:'),
                    const SizedBox(height: 16),
                    const Text('1. Go to your device WiFi settings'),
                    const SizedBox(height: 8),
                    Text('2. Connect to: ${module.name}'),
                    const SizedBox(height: 8),
                    const Text('3. Use password: 12345678'),
                    const SizedBox(height: 8),
                    const Text('4. Return to this app and tap Continue'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Device ID: ${module.macAddress.replaceAll(':', '').toUpperCase()}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
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
                    child: const Text('Continue'),
                  ),
                ],
              ),
        ) ??
        false;

    if (!shouldContinue) return;

    await ref.read(wifiProvisioningProvider.notifier).connectToModule(module);

    final provisioningState = ref.read(wifiProvisioningProvider);
    if (provisioningState.status == ProvisioningStatus.connected &&
        context.mounted) {
      context.go('/wifi-credentials');
    } else if (provisioningState.status == ProvisioningStatus.error &&
        context.mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Connection Failed'),
              content: Text(
                provisioningState.errorMessage ??
                    'Could not connect to the module. Please ensure:\n\n'
                        '• You are connected to the module\'s WiFi network\n'
                        '• The module is in provisioning mode\n'
                        '• Try refreshing the scan and connecting again',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _checkPermissions(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(provisioningRepositoryProvider);

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

    final hasPermissions = await repository.checkPermissions();

    if (context.mounted) {
      Navigator.of(context).pop(); // Close loading dialog

      if (hasPermissions) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions are granted. Try refreshing the scan.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final shouldRequest =
            await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Permissions Required'),
                    content: const Text(
                      'WiFi scanning permissions are not granted. Would you like to request them again?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Request'),
                      ),
                    ],
                  ),
            ) ??
            false;

        if (shouldRequest) {
          await repository.requestPermissions();

          // Check again
          final finalPermissions = await repository.checkPermissions();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  finalPermissions
                      ? 'Permissions granted! Try scanning again.'
                      : 'Permissions still not granted. Please enable them in Settings.',
                ),
                backgroundColor: finalPermissions ? Colors.green : Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  void _showNetworkInfo(BuildContext context, NexLockModule module) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Network Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Network: ${module.name}'),
                const SizedBox(height: 8),
                Text('BSSID: ${module.macAddress}'),
                const SizedBox(height: 8),
                Text('Signal: ${module.rssi} dBm'),
                const SizedBox(height: 16),
                const Text(
                  'This is a regular WiFi network, not a NexLock module.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Color _getSignalColor(int rssi) {
    if (rssi > -50) return Colors.green;
    if (rssi > -70) return Colors.orange;
    return Colors.red;
  }

  String _getSignalStrength(int rssi) {
    if (rssi > -50) return 'Excellent';
    if (rssi > -60) return 'Good';
    if (rssi > -70) return 'Fair';
    return 'Weak';
  }

  Future<void> _testWiFiDirectly(BuildContext context, WidgetRef ref) async {
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
                Text('Testing WiFi scanning directly...'),
              ],
            ),
          ),
    );

    try {
      print('=== DIRECT WIFI TEST ===');

      // Import wifi_scan directly
      final results = await WiFiScan.instance.getScannedResults();
      print('Direct scan found ${results.length} networks');

      for (int i = 0; i < results.length && i < 10; i++) {
        final ap = results[i];
        print('Network $i: "${ap.ssid}" (${ap.level} dBm)');
      }

      if (context.mounted) {
        Navigator.of(context).pop();

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Direct WiFi Test Results'),
                content: Text(
                  'Found ${results.length} networks.\n\n'
                  'First few networks:\n'
                  '${results.take(5).map((ap) => '• ${ap.ssid.isEmpty ? '[Hidden]' : ap.ssid} (${ap.level} dBm)').join('\n')}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      print('Direct WiFi test failed: $e');

      if (context.mounted) {
        Navigator.of(context).pop();

        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Direct WiFi Test Failed'),
                content: Text('Error: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> _addManualModule(BuildContext context, WidgetRef ref) async {
    final ssidController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Module Manually'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please enter the SSID (WiFi name) of your NexLock module:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ssidController,
                  decoration: const InputDecoration(
                    labelText: 'Module SSID',
                    hintText: 'e.g., NexLock_123ABC',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (ssidController.text.isNotEmpty) {
                    Navigator.of(
                      context,
                    ).pop({'ssid': ssidController.text.trim()});
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );

    if (result != null && context.mounted) {
      final manualModule = NexLockModule(
        name: result['ssid'],
        deviceName: result['ssid'],
        macAddress: 'manual-${DateTime.now().millisecondsSinceEpoch}',
        rssi: -65,
      );

      // Simulate a connection process
      _connectToModule(context, ref, manualModule);
    }
  }
}
