import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/provisioning_provider.dart';

class ProvisioningStatusScreen extends ConsumerWidget {
  const ProvisioningStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provisioningState = ref.watch(wifiProvisioningProvider);
    final status = provisioningState.status;
    final selectedModule = provisioningState.selectedModule;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provisioning Status'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusIcon(status),
            const SizedBox(height: 32),
            _buildStatusTitle(status),
            const SizedBox(height: 16),
            _buildStatusMessage(status, selectedModule?.name),
            if (provisioningState.errorMessage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    provisioningState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 48),
            if (status == ProvisioningStatus.success) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.info, color: Colors.green),
                      const SizedBox(height: 8),
                      const Text(
                        'What happens next?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The module is now connected to your WiFi network and ready to be configured by the superadmin.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            _buildActionButton(context, ref, status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ProvisioningStatus status) {
    switch (status) {
      case ProvisioningStatus.success:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 64, color: Colors.green),
        );
      case ProvisioningStatus.error:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error, size: 64, color: Colors.red),
        );
      default:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 6,
            color: Color(0xFF1E88E5),
          ),
        );
    }
  }

  Widget _buildStatusTitle(ProvisioningStatus status) {
    String title;
    switch (status) {
      case ProvisioningStatus.success:
        title = 'Provisioning Complete!';
        break;
      case ProvisioningStatus.error:
        title = 'Provisioning Failed';
        break;
      default:
        title = 'Provisioning in Progress';
    }

    return Text(
      title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStatusMessage(ProvisioningStatus status, String? moduleName) {
    String message;
    switch (status) {
      case ProvisioningStatus.success:
        message =
            'The NexLock module "${moduleName ?? 'Unknown'}" has been successfully configured with WiFi credentials and is now ready for use.';
        break;
      case ProvisioningStatus.error:
        message =
            'Failed to provision the module. Please check your WiFi credentials and try again.';
        break;
      default:
        message =
            'Configuring the module with WiFi credentials. Please wait...';
    }

    return Text(
      message,
      style: const TextStyle(fontSize: 16, color: Colors.grey),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    ProvisioningStatus status,
  ) {
    switch (status) {
      case ProvisioningStatus.success:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _resetAndGoHome(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Provision Another Module',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        );
      case ProvisioningStatus.error:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Try Again', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _resetAndGoHome(BuildContext context, WidgetRef ref) {
    // Reset provisioning state
    ref.read(wifiProvisioningProvider.notifier).reset();

    // Navigate to home
    context.go('/home');
  }
}
