import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

const _onboardingCompleteKey = 'onboarding_complete';

class App extends StatefulWidget {
  const App({required this.home, super.key});

  final Widget home;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final Future<bool> _initialization = _loadOnboardingStatus();
  SharedPreferences? _preferences;
  bool? _onboardingComplete;

  Future<bool> _loadOnboardingStatus() async {
    _preferences = await SharedPreferences.getInstance();
    return _preferences!.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> _completeOnboarding() async {
    final preferences = _preferences;
    if (preferences == null) {
      throw StateError('App preferences are not initialized.');
    }

    final saved = await preferences.setBool(_onboardingCompleteKey, true);
    if (!saved) {
      throw StateError('Could not save onboarding completion.');
    }

    if (mounted) setState(() => _onboardingComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Store',
      theme: buildAppTheme(),
      home: FutureBuilder<bool>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not load app settings: ${snapshot.error}'),
                ),
              ),
            );
          }

          final onboardingComplete =
              _onboardingComplete ?? snapshot.data ?? false;
          if (!snapshot.hasData && _onboardingComplete == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return onboardingComplete
              ? widget.home
              : OnboardingScreen(onComplete: _completeOnboarding);
        },
      ),
    );
  }
}
