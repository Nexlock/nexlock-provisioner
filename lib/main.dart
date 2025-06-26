import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:esp_provisioning_wifi/esp_provisioning_bloc.dart';
import 'package:go_router/go_router.dart';
import 'features/provisioning/presentation/pages/splash_screen.dart';
import 'features/provisioning/presentation/pages/home_screen.dart';
import 'features/provisioning/presentation/pages/wifi_credentials_screen.dart';
import 'features/provisioning/presentation/pages/provisioning_status_screen.dart';
import 'features/provisioning/presentation/widgets/module_scanner_widget.dart';

void main() {
  runApp(const ProviderScope(child: NexLockProvisionerApp()));
}

class NexLockProvisionerApp extends StatelessWidget {
  const NexLockProvisionerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EspProvisioningBloc(),
      child: MaterialApp.router(
        title: 'NexLock Provisioner',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF1E88E5),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const ModuleScannerScreen(),
    ),
    GoRoute(
      path: '/wifi-credentials',
      builder: (context, state) => const WiFiCredentialsScreen(),
    ),
    GoRoute(
      path: '/provisioning-status',
      builder: (context, state) => const ProvisioningStatusScreen(),
    ),
  ],
);

class ModuleScannerScreen extends StatelessWidget {
  const ModuleScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan for Modules'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: ModuleScannerWidget(),
      ),
    );
  }
}
