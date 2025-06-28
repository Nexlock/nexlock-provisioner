import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../domain/entities/nexlock_module.dart';
import '../../domain/entities/wifi_credentials.dart';

// Re-export use cases from DI
final scanForModulesProvider = scanForModulesUseCaseProvider;
final connectToModuleProvider = connectToModuleUseCaseProvider;
final provisionWiFiProvider = provisionWiFiUseCaseProvider;

// State Providers
final scannedModulesProvider = StreamProvider<List<NexLockModule>>((
  ref,
) async* {
  try {
    print('=== WiFi Module Scanning Started ===');

    final repository = ref.watch(provisioningRepositoryProvider);

    // Check permissions first with timeout
    print('Step 1: Checking permissions...');
    final hasPermissions = await Future.any([
      repository.checkPermissions(),
      Future.delayed(
        const Duration(seconds: 5),
        () => false,
      ), // Timeout fallback
    ]);

    print('Permissions check result: $hasPermissions');

    if (!hasPermissions) {
      print('Step 2: Requesting permissions...');
      await repository.requestPermissions();

      // Check again with shorter timeout
      final permissionsGranted = await Future.any([
        repository.checkPermissions(),
        Future.delayed(const Duration(seconds: 3), () => false),
      ]);

      print('Final permissions result: $permissionsGranted');

      if (!permissionsGranted) {
        print('ERROR: WiFi scanning permissions not granted');
        throw Exception('WiFi scanning permissions not granted');
      }
    }

    print('Step 3: Starting WiFi scan...');

    // Start scanning with the use case
    final scanUseCase = ref.watch(scanForModulesProvider);

    // Add a timeout to the stream to prevent infinite waiting
    yield* scanUseCase()
        .timeout(
          const Duration(seconds: 30),
          onTimeout: (sink) {
            print('WARNING: WiFi scan timed out, yielding empty list');
            sink.add(<NexLockModule>[]);
          },
        )
        .map((modules) {
          print('=== Scan Results Received ===');
          print(
            'Found ${modules.length} modules: ${modules.map((m) => m.name).join(', ')}',
          );
          return modules;
        })
        .handleError((error) {
          print('ERROR in scan stream: $error');
          return <NexLockModule>[];
        });
  } catch (e, stackTrace) {
    print('FATAL ERROR in scanning provider: $e');
    print('Stack trace: $stackTrace');
    yield <NexLockModule>[];
  }
});

final selectedModuleProvider = StateProvider<NexLockModule?>((ref) => null);

final isConnectedProvider = StateProvider<bool>((ref) => false);

final provisioningStatusProvider = StateProvider<ProvisioningStatus>(
  (ref) => ProvisioningStatus.idle,
);

final errorMessageProvider = StateProvider<String?>((ref) => null);

// Provisioning status with better connection and provisioning flow
enum ProvisioningStatus {
  idle,
  checkingPermissions,
  scanning,
  connecting,
  connected,
  provisioning,
  success,
  error,
}

// Provider for handling WiFi provisioning flow
final wifiProvisioningProvider =
    StateNotifierProvider<WiFiProvisioningNotifier, WiFiProvisioningState>((
      ref,
    ) {
      return WiFiProvisioningNotifier(ref);
    });

class WiFiProvisioningState {
  final ProvisioningStatus status;
  final String? errorMessage;
  final NexLockModule? selectedModule;
  final bool isConnected;

  const WiFiProvisioningState({
    required this.status,
    this.errorMessage,
    this.selectedModule,
    this.isConnected = false,
  });

  WiFiProvisioningState copyWith({
    ProvisioningStatus? status,
    String? errorMessage,
    NexLockModule? selectedModule,
    bool? isConnected,
  }) {
    return WiFiProvisioningState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      selectedModule: selectedModule ?? this.selectedModule,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class WiFiProvisioningNotifier extends StateNotifier<WiFiProvisioningState> {
  final Ref ref;

  WiFiProvisioningNotifier(this.ref)
    : super(const WiFiProvisioningState(status: ProvisioningStatus.idle));

  Future<void> connectToModule(NexLockModule module) async {
    print('Connecting to module: ${module.name}');

    state = state.copyWith(
      status: ProvisioningStatus.connecting,
      selectedModule: module,
      errorMessage: null,
    );

    try {
      final connectUseCase = ref.read(connectToModuleProvider);
      final success = await connectUseCase(module);

      if (success) {
        print('Successfully connected to module: ${module.name}');
        state = state.copyWith(
          status: ProvisioningStatus.connected,
          isConnected: true,
        );
      } else {
        print('Failed to connect to module: ${module.name}');
        state = state.copyWith(
          status: ProvisioningStatus.error,
          errorMessage:
              'Failed to connect to module. Please ensure the module is in provisioning mode and try again.',
        );
      }
    } catch (e) {
      print('Connection error: $e');
      state = state.copyWith(
        status: ProvisioningStatus.error,
        errorMessage: 'Connection error: ${e.toString()}',
      );
    }
  }

  Future<void> provisionWiFi(WiFiCredentials credentials) async {
    print('Starting WiFi provisioning...');

    state = state.copyWith(
      status: ProvisioningStatus.provisioning,
      errorMessage: null,
    );

    try {
      final provisionUseCase = ref.read(provisionWiFiProvider);
      final success = await provisionUseCase(credentials);

      if (success) {
        print('WiFi provisioning completed successfully');
        state = state.copyWith(status: ProvisioningStatus.success);

        // Disconnect from module after successful provisioning
        await _disconnectFromModule();
      } else {
        print('WiFi provisioning failed');
        state = state.copyWith(
          status: ProvisioningStatus.error,
          errorMessage:
              'Failed to provision WiFi. Please check your credentials and try again.',
        );
      }
    } catch (e) {
      print('Provisioning error: $e');
      state = state.copyWith(
        status: ProvisioningStatus.error,
        errorMessage: 'Provisioning error: ${e.toString()}',
      );
    }
  }

  Future<void> _disconnectFromModule() async {
    try {
      print('Disconnecting from module...');
      final repository = ref.read(provisioningRepositoryProvider);
      await repository.disconnect();
      print('Successfully disconnected from module');
    } catch (e) {
      print('Error disconnecting from module: $e');
    }
  }

  void reset() {
    print('Resetting WiFi provisioning state...');
    state = const WiFiProvisioningState(status: ProvisioningStatus.idle);
    _disconnectFromModule();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
