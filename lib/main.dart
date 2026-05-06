import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'models/participant.dart';
import 'models/event.dart';
import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/event_setup_screen.dart';
import 'screens/check_in_screen.dart';
import 'screens/logs_screen.dart';
import 'providers/event_provider.dart';
import 'providers/user_role_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/attendee_pass_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  // Register Adapters
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ParticipantAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(EventAdapter());
  
  final settingsBox = await Hive.openBox('settings');
  final bool onboardingComplete = settingsBox.get('onboarding_complete', defaultValue: false);

  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => MyApp(onboardingComplete: onboardingComplete),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool onboardingComplete;
  const MyApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventProvider);
    final role = ref.watch(userRoleProvider);

    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'QRifyME',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: _getHome(onboardingComplete, role, event),
    );
  }

  Widget _getHome(bool onboarding, UserRole role, Event? event) {
    if (!onboarding) return const OnboardingScreen();
    if (role == UserRole.none) return const AuthScreen();
    if (role == UserRole.host && event == null) return const EventSetupScreen();
    return const MainNavigation();
  }
}



class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  final List<Widget> _screens = [
    const DashboardScreen(),
    const CheckInScreen(),
    const LogsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    final role = ref.watch(userRoleProvider);
    final isHost = role == UserRole.host;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isHost ? _screens[currentIndex] : (currentIndex == 0 ? const AttendeePassScreen() : const SettingsScreen()),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          height: 70,
          onDestinationSelected: (index) {
            ref.read(navigationProvider.notifier).state = index;
          },
          destinations: isHost 
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryPurple),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.qr_code_scanner_rounded),
                  selectedIcon: Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primaryPurple),
                  label: 'Check-in',
                ),
                NavigationDestination(
                  icon: Icon(Icons.list_alt_rounded),
                  selectedIcon: Icon(Icons.list_alt_rounded, color: AppTheme.primaryPurple),
                  label: 'Logs',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded, color: AppTheme.primaryPurple),
                  label: 'Settings',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.confirmation_num_outlined),
                  selectedIcon: Icon(Icons.confirmation_num_rounded, color: AppTheme.primaryPurple),
                  label: 'My Pass',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded, color: AppTheme.primaryPurple),
                  label: 'Settings',
                ),
              ],
        ),
      ),
    );
  }
}
