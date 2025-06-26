import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/nexlock_module.dart';
import '../providers/provisioning_provider.dart';

class ModuleScannerWidget extends ConsumerWidget {
  const ModuleScannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(scannedModulesProvider);
    final provisioningStatus = ref.watch(provisioningStatusProvider);

    return Column(
      children: [
        const Text(
          'Scanning for NexLock Modules...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (provisioningStatus == ProvisioningStatus.scanning)
          const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Expanded(
          child: modulesAsync.when(
            data: (modules) {
              if (modules.isEmpty) {
                return const Center(
                  child: Text(
                    'No NexLock modules found.\nMake sure the module is in provisioning mode and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: Text(module.name),
                      subtitle: Text(
                        'MAC: ${module.macAddress}\nTap to connect',
                      ),
                      trailing:
                          provisioningStatus == ProvisioningStatus.connecting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.arrow_forward_ios),
                      onTap:
                          provisioningStatus == ProvisioningStatus.connecting
                              ? null
                              : () async {
                                ref
                                    .read(selectedModuleProvider.notifier)
                                    .state = module;
                                ref
                                    .read(provisioningStatusProvider.notifier)
                                    .state = ProvisioningStatus.connecting;

                                final connectUseCase = ref.read(
                                  connectToModuleProvider,
                                );
                                final success = await connectUseCase(module);

                                if (success) {
                                  ref.read(isConnectedProvider.notifier).state =
                                      true;
                                  ref
                                      .read(provisioningStatusProvider.notifier)
                                      .state = ProvisioningStatus.connected;
                                  if (context.mounted) {
                                    context.go('/wifi-credentials');
                                  }
                                } else {
                                  ref
                                      .read(provisioningStatusProvider.notifier)
                                      .state = ProvisioningStatus.error;
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Failed to connect to module. Please try again.',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
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
                      Text('Initializing Bluetooth scanning...'),
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
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Refresh the provider
                          ref.invalidate(scannedModulesProvider);
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
